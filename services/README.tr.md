# services

Backend servisleri. **Dart workspace üyesi değildir** — Melos ve pub bu ağacı
görmez, `melos version` bunu sürümleyemez.

Bu yapının neden böyle seçildiğinin otoritesi
[architecture/backend.tr.md](../architecture/backend.tr.md); bu dosya günlük
kullanım içindir.

> 🇬🇧 For English: [README.md](README.md)

## Gereksinimler

JDK 21 ve çalışan bir konteyner motoru (Colima, OrbStack veya Docker Desktop).
Maven wrapper'dan gelir — kurulu `mvn` değil, `./mvnw` kullanılır.

```bash
cd services
./mvnw -B verify
```

## Yerleşim

```
services/
├─ pom.xml     parent: Quarkus BOM, eklenti sürümleri, Jandex
└─ core/       kütüphane modülü — her servise derlenir, ağ üzerinden çağrılmaz
```

Uygulama başına bir çalıştırılabilir modül ilk servisle gelecek. Servisler
çalışma anında birbiriyle konuşmaz: `auth` bir JWT üretir, her servis onu public
key ile yerel olarak doğrular.

## Yeni modül eklemek

1. Dizini oluştur, `services/pom.xml`'e `<module>` ekle.
2. **Kütüphane modülü Jandex eklentisini bildirir.** Quarkus indeks olmadan
   bağımlılık jar'larındaki CDI bean'lerini bulamaz; indekssiz kütüphane sorunsuz
   başlar ve sessizce bean'siz kalır. Konfigürasyon parent'ta hazır, modül
   yalnızca eklentiyi bildirir.
3. Çalıştırılabilir modül bunun yerine `quarkus-maven-plugin` bildirir.
4. Paketleme katmana göre değil **özelliğe göre**, `com.dafalabs.api.<app>`
   altında. Küçük bir özellik tek dosyadır; katmanlar ihtiyaç doğduğunda çıkar.

## Hata sözleşmesi

Yakalama, fırlat. Resource bir istisnayı durum koduna çevirmez:

```java
throw new CustomRuntimeException(409, "cooldown_open", "Yeni motto için beklemen gerekiyor.");
```

- `code` sabit, snake_case ve makine tarafından okunabilir. İstemci buna göre
  dallanır; mesajın ifadesi serbestçe değişebilir.
- **5xx kendi mesajını asla döndürmez.** Gerçek sebep, çağırana verilen
  `traceId` ile birlikte log'a gider — "hata aldım" diyen kullanıcı böylece
  aranabilir bir şey vermiş olur.
- Geri kalan her şeyi `UnhandledExceptionMapper` yakalar, sözleşme gerçekten
  hepsini kapsar. Gövdesi zaten dolu olan bir `WebApplicationException` olduğu
  gibi geçer; o dal için henüz birim test yok, çünkü çalışan bir uç gerekiyor ve
  ilk servisle birlikte gelecek.

## Konfigürasyon

Paylaşılan varsayılanlar
`core/src/main/resources/META-INF/microprofile-config.properties` içinde. Öncelik
aşağıdan yukarı: bu varsayılanlar, sonra servisin kendi `application.properties`
dosyası, sonra ortam değişkenleri.

**Hiçbir sır bu depoya girmez.** Sırlar ortam değişkeni olarak gelir, yalnızca
ortam değişkeni olarak.

Swagger UI bir dev profili özelliğidir: servis onu `%dev` altında açabilir,
stage ve prod için asla.

## Quarkus sürümü

Tek yerde, parent'ta, `quarkus.platform.version` olarak sabit. LTS branşı yerine
güncel sürümü takip eder: burada henüz legacy hiçbir şey yok, Dependabot sürümü
ilerletiyor ve bir bump'ın kırdığını CI yakalıyor. Aylık bump'lar gürültüye
dönüşürse LTS branşına geçmek bu tek property.

## CI

`Services CI` her pull request'te koşar, `services/` değişti mi kendisi karar
verir ve **Build & test services** adlı iş üzerinden rapor verir. İş path'e göre
filtrelenir, kapı filtrelenmez — üst seviye `paths:` filtresiyle atlanan bir
workflow hiç status bildirmez ve hiç bildirmeyen zorunlu kontrol PR'ı sonsuza
kadar bloklar.

> **Elle yapılacak bir adım kaldı:** `Build & test services` henüz
> `main-protection` ruleset'inde listelenmiyor, yani rapor veriyor ama
> bloklayamıyor. GitHub → Settings → Rules altından ekleyince kapıya dönüşür.

Native build ve `@QuarkusIntegrationTest` pull request'e değil merge'e aittir;
ilk dağıtılabilir servisle gelecek.
