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

### Colima

Testler Dev Services ile bir PostgreSQL konteyneri açar ve Testcontainers'ın
Docker soketine, konteyner motorunun gördüğü yoldan erişmesi gerekir. Colima'da
bu varsayılan değildir ve hata alakasız görünür: *"Container startup failed for
image testcontainers/ryuk"*. Bir kez şunu dışa aktar:

```bash
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
```

Docker Desktop, OrbStack ve CI runner'ları için gerekmiyor.

## Yerleşim

```
services/
├─ pom.xml     parent: Quarkus BOM, eklenti sürümleri, Jandex
├─ core/       kütüphane modülü — her servise derlenir, ağ üzerinden çağrılmaz
├─ auth/       çalıştırılabilir — cihaz hash'ini kimliğe çevirir ve token'ını imzalar
└─ motto/      çalıştırılabilir — motto uygulamasının API'si
```

Uygulama başına bir çalıştırılabilir modül, modül başına bir alt alan adı: bir
uygulamanın API'sindeki değişiklik diğer uygulamaların üretilmiş istemcilerine
dokunmaz. Tek ortak şema olsaydı, bir uygulamanın istediği tek alan için bütün
istemciler yeniden üretilirdi.

Uygulama başına bir çalıştırılabilir modül ilk uygulama servisiyle gelecek.
Servisler çalışma anında birbiriyle konuşmaz: `auth` bir JWT üretir, her servis
onu public key ile yerel olarak doğrular — bu yüzden `auth`'a ulaşan tek istek
bir kayıttır.

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

- `code` sabit, snake_case, makine tarafından okunabilir ve **sözleşmenin
  kendisidir**. Bir istemci ona bağlandıktan sonra değişmez.
- `message` İngilizcedir ve log'a ya da başarısız isteğe bakan kişi içindir.
  **Kullanıcının gördüğü şey asla o değildir.** Kullanıcıya gösterilen metni
  istemci `code`'dan üretir, kendi dilinde — paylaşılan bir kütüphane, kendisine
  bağlanan her uygulama adına kullanıcıların hangi dili konuştuğuna karar
  vermeden kullanıcı metni tutamaz.
- **5xx kendi mesajını asla döndürmez.** Gerçek sebep, çağırana verilen
  `traceId` ile birlikte log'a gider — "hata aldım" diyen kullanıcı böylece
  aranabilir bir şey vermiş olur.
- Geri kalan her şeyi `UnhandledExceptionMapper` yakalar, sözleşme gerçekten
  hepsini kapsar. Gövdesi zaten dolu olan bir `WebApplicationException` olduğu
  gibi geçer; o dal için henüz birim test yok, çünkü çalışan bir uç gerekiyor ve
  ilk servisle birlikte gelecek.

## Kimlik

Bir şey satın alınana kadar hesap yok, dolayısıyla kimlik cihazdır. Uygulama
Keychain'de ya da `Settings.Secure.ANDROID_ID` içinde tuttuğu kimliği hash'ler
ve hash'i gönderir; ham kimlik sunucuya hiç ulaşmaz — `devices` tablosunu
sızdığında bile sıkıcı yapan şey budur.

`POST /v1/devices/register` bilinçli olarak idempotenttir: aynı hash ile tekrar
kayıt, zaten var olan kimliği döndürür. Bu sürekli olur, çünkü token kısa
ömürlüdür ve **refresh akışı yoktur** — hesap yokken ayakta tutulacak oturum da
yoktur, uygulama sadece yeniden kaydolur.

Sonucunu açıkça yazmak gerekir: cihaz hash'i kimlik bilgisinin kendisidir. Onu
elinde tutan token alabilir. Hesapsız ürünün doğal sonucudur; sertleştirmesi hız
sınırı ve ileride platform attestation'dır.

İmzalama anahtarları depoda durmaz; tek istisna `auth/dev-keys/` altındaki
değersiz çifttir (kendi README'sine bak). Paketlenen uygulamada hiç anahtar
tanımlı değildir: `SMALLRYE_JWT_SIGN_KEY` unutulursa servis bilinen bir
anahtara düşmek yerine imzalama anında patlar.

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

Native build ve `@QuarkusIntegrationTest` pull request'te değil merge'de,
**motto release** içinde koşar — pull request hızlı cevap ister. O workflow elle
de tetiklenebilir; native derlemeyi merge'den önce dalda kanıtlamanın yolu bu —
ikinci sürümden itibaren, çünkü GitHub elle tetiklemeyi yalnızca varsayılan dalda
zaten bulunan workflow'lar için sunuyor.
`main` dışından tetiklenirse imajı basar ve durur, çünkü bir dalı stage'e
göndermek tek tık uzakta olmamalı.

**motto promote** mevcut imajı digest ile prod'a taşır, yeniden derlemez.
Sunucunun neye ihtiyacı olduğu [motto/deploy/README.md](motto/deploy/README.md)
içinde.
