# Backend

> 🇬🇧 For English: [backend.md](backend.md)

Reponun Flutter tarafı bir Dart pub workspace'i. Backend değil — yanında,
`services/` altında duruyor ve Melos onu görmüyor. Aşağıdakiler aldığı şekil ve
her kararın gerekçesi.

## Neden burada

Tek bir sebep, ve yeterli: **OpenAPI şeması ile onu tüketen Dart client aynı
commit'te değişiyor.** Şema değişikliği ve ona bağlı app kodu birlikte review
ediliyor, yeni şemaya karşı kırılacak bir app aynı pull request'te derlenmiyor.
Backend'i ayrı repoya koymak, "backend deploy oldu app kırıldı" senaryosunu
mümkün kılan şeydir.

Bedeli gerçek ve kabul edilmiş durumda: Dart workspace'i bir Java modülü
taşıyamıyor, `melos version` onu sürümleyemiyor, CI ikinci bir toolchain
kazanıyor.

## Yerleşim

```
fatiharge-apps/
├─ apps/                       # Flutter (Dart workspace)
├─ packages/
│  └─ api_client_<app>/        # üretilmiş Dart client, elle düzenlenmez
├─ services/                   # Dart workspace ÜYESİ DEĞİL
│  ├─ pom.xml                  # parent: Quarkus BOM, plugin'ler, Jandex
│  ├─ core/                    # kütüphane modülü — user, auth, subscription
│  ├─ auth/                    # çalışabilir — JWT üretir
│  └─ <app>/                   # çalışabilir — app başına bir tane
├─ contracts/
│  └─ <app>.v1.json            # build'de üretilir, commit edilir, CI'da denetlenir
└─ architecture/
```

## Modüller

Maven multi-module. `core` bir **kütüphane**: ağ üzerinden çağrılmak yerine her
servisin içine derleniyor. Servisler çalışma zamanında birbiriyle konuşmuyor —
`auth` JWT üretiyor, her servis onu public key ile yerel olarak doğruluyor, yani
`auth`'a ulaşan tek istek login.

App başına bir çalışabilir modül, çalışabilir modül başına bir subdomain. Bu
erken mikroservis değil: bir app'in API'sindeki değişikliğin diğer app'lerin
client'ına dokunmaması için var. Tek ortak şema, tek app'in istediği bir alan
için on beş client'ı yeniden üretirdi.

**Jandex.** Quarkus, bağımlılık jar'larındaki CDI bean'lerini Jandex index'i
olmadan keşfetmiyor. `jandex-maven-plugin` almayan bir kütüphane modülü sorunsuz
ayağa kalkıyor ve sessizce hiç bean taşımıyor. Parent pom'da bir kez tanımlanır.

## Dosya ağacı

Katman değil, özellik:

```
com/dafalabs/api/<app>/
├─ transaction/
│  ├─ TransactionResource.java
│  ├─ TransactionService.java
│  ├─ Transaction.java
│  ├─ TransactionRepository.java
│  └─ dto/
└─ budget/
```

Küçük bir feature tek dosya olabilir. Katmanlar, feature onlara büyüdüğünde
çıkar; öncesinde değil. `core` da aynı şekilde, artı hatalar için çapraz kesen
tek bir paket.

## Kurallar

- **Resource'lar DTO döner, entity değil.** Tel üstündeki entity, veritabanı
  şeklini sözleşmeye koyar ve tablo değiştikçe sözleşme değişir.
- **Yollar sürümlüdür:** `/v1/…`. Kırıcı değişiklik `/v2` açar; `/v1`'e asla
  dokunulmaz ve kimse çağırmayana kadar ayakta kalır.
- **`@Authenticated` resource sınıfında**, metot başına değil. Bir metodu
  unutmak kolay, bir sınıfı unutmak zor.
- **Tek hata sözleşmesi.** Her istisna `CustomRuntimeException`'dan türer ve
  kendi HTTP durumunu taşır; tek bir `ExceptionMapper` hepsini yazar.
- **`quarkus-hibernate-orm-rest-data-panache` kullanılmaz.** CRUD endpoint'leri
  üretiyor, bu da okunması beklenen bir şemayla çelişiyor.
- **Flyway, asla `hibernate-orm.database.generation`.** Otomatik DDL kolon
  silemez, yeniden adlandıramaz, review edilemez ve geri alınamaz.
- **Config ortam değişkeninden.** Repoya hiçbir sır girmez.
- **Swagger UI bir dev profili özelliğidir.** Stage'e ve prod'a gitmez.

## Veri

Tek PostgreSQL, servis başına bir şema: `core.users`, `<app>.…`. Bir servis
yalnızca kendi şemasına yazar. Flyway konumları modül başına, yani her servis
kendi migration'larını taşır.

Veritabanına yalnızca internal Docker ağından erişilir. Traefik route'u ve
yayımlanmış portu yoktur.

## Sözleşme

Code-first. Resource'lar ve DTO'lar kaynak; SmallRye şemayı build'de üretiyor;
şema commit ediliyor; Dart client commit'li dosyadan üretiliyor.

```
resource + DTO
   ↓ mvn package
contracts/<app>.v1.json        commit'li
   ↓ openapi-generator
packages/api_client_<app>      üretilmiş, elle düzenlenmez
```

Resource'lar düz DTO döndüğü sürece şema ile implementasyon arasında sapma
mümkün değil — şema, endpoint'in döndüğü tiplerin ta kendisinden türüyor. Bunu
koruyan iki disiplin var:

- **Her endpoint `@Operation(operationId = "…")` yazar.** Yoksa üretilen Dart
  metot adı Java metot adından türer ve bir metodu yeniden adlandırmak client'ın
  API'sini sessizce yeniden adlandırır.
- **`@Schema` ile tip ezilmez.** DTO ne diyorsa şema odur.

CI şema başına iki kapı tutar: commit'li dosya güncel mi
(`git diff --exit-code contracts/`), ve `oasdiff` bir değişiklik `/v1`'i
kırdığında build'i düşürür.

## Ortamlar

| | nerede | neden |
| --- | --- | --- |
| **dev** | lokal, `quarkus dev` | Dev Services PostgreSQL'i container'da kaldırıyor ve canlı yeniden yükleme çalışıyor. Deploy edilmiş bir dev ortamı bundan kötü ve servis başına bir container daha demek. |
| **stage** | `<app>.stage.dafalabs.com` | gerçek deploy, gerçek veritabanı |
| **prod** | `<app>.dafalabs.com` | elle tetiklenir |

**İmaj bir kez derlenir.** Stage'in çalıştırdığı imaj prod'a digest ile terfi
eder — prod asla yeniden derlemez. Yeniden derlemek, "stage'de çalışıyordu"
cümlesini anlamsız kılan şeydir. İmajlar `ghcr.io`'da durur; repo public olduğu
için tek gereken kimlik `GITHUB_TOKEN`.

Her ortamın kendi veritabanı instance'ı var. Konfigürasyon Quarkus profilleri
(`%dev`, `%stage`, `%prod`) artı ortam değişkenlerinden gelir, GitHub
Environments içinde tutulur.

## CI

Baştan native, ama her push'ta değil:

| olay | ne koşar |
| --- | --- |
| pull request | yalnızca değişen servisler: JVM build + `@QuarkusTest` |
| `main`'e merge | değişen servisler: native build + `@QuarkusIntegrationTest` → imaj → stage |
| prod | `workflow_dispatch`, mevcut imajı terfi ettirir |

Hedef native olduğunda `@QuarkusIntegrationTest` isteğe bağlı değil. Derlenmiş
binary'ye karşı koşuyor; orada yansıma ve kaynak yükleme farklı davranıyor.
`@QuarkusTest` JVM'de koşar ve o hataları göremez. Native imajlar container'da
derlenir, hiçbir runner'a GraalVM kurulmaz.

**Tetikleme.** Mantığı tek bir yeniden kullanılabilir workflow taşır; servis
başına ince bir çağırıcı yalnızca kendi `paths` filtresini taşır. Bir servisin
filtresi kendi dizininin yanında `services/core/**` ve `services/pom.xml`'i de
içerir — kütüphane değişikliği onu içine alan her şeyi yeniden derlemelidir.

**Zorunlu kontrol tuzağı.** `paths` filtresiyle atlanan bir workflow hiç status
bildirmiyor, hiç bildirmeyen zorunlu bir kontrol de pull request'i sonsuza kadar
blokluyor. Bu yüzden iş koşullu ama kapı değil: son bir job `if: always()` ile
koşuyor ve yalnızca bağlı olduğu bir şey düştüğünde düşüyor. `main-protection`'ın
zorunlu tuttuğu job odur.
