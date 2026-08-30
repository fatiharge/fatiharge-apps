# Uygulama katmanları

> 🇬🇧 For English: [app-layers.md](app-layers.md)

Bir şeyin uygulama içinde nereye gittiği ve neden. [`overview.tr.md`](overview.tr.md)
depoyu anlatır; bu doküman tek bir Flutter uygulamasını anlatır ve baştan sona
`apps/motto`'yu kullanır, çünkü her katmanı içinde barındıran o.

## Şekil

```
features/<özellik>/
  domain/         saf Dart: kurallar, değer tipleri. Flutter yok, IO yok.
  application/    cubit, repository, store. Sunucuyu bilir, ekranı bilmez.
  presentation/   sayfalar ve widget'lar. Ekranı bilir, sunucuyu bilmez.
infrastructure/   uygulamanın tamamının ihtiyacı: oturum, api, efektler, analitik.
route/            router ve ona bağlı olanlar.
config/           container, ortam, çökme raporlama.
```

Bu adlardan üçü yük taşıyor ve aşağıda açıklanıyor. Gerisi zaten tahmin
edeceğin yerde.

## Store, repository, cubit

İnsanın en çok vaktini alan ayrım, o yüzden başta.

**Store**, bir değerin oturumlar arasında nerede durduğudur. Başka hiçbir şey.
Anahtarı, serileştirmeyi ve "ya bozuksa" sorusunun cevabını o taşır. Hiçbir
karar vermez.

**Repository**, bir değerin *nereden geleceğine* karar verir — birden fazla
kaynak olduğunda. `ChainRepository`'nin iki kaynağı var, sunucu ve
`ChainStore`, ve tek işi aralarında seçim yapmak: ekran hemen çizsin diye önce
cache, ağ başarısız olunca kuyruk, cevap gelince sunucu.

**Cubit**, tek bir ekranın durumu ve akışıdır. Repository'leri çağırır;
onlar cubit'i asla çağırmaz.

Yani bir özelliğin repository'si ancak uzlaştırılacak bir şey varsa olur.
Motto'nun altı store'unun dördünde yok, ve bu bir eksiklik değil:

| Store | Repository | Neden |
| --- | --- | --- |
| `chain_store` | var | sunucu cache'i ve çevrimdışı kuyruk |
| `task_store` | var | aynısı, günün üç şeyi için |
| `content_store` | var | indirilen paket, ETag ile sürümlü |
| `effect_store` | var | aynısı, reddin nereye götürdüğü için |
| `token_store` | yok | Keychain, ömürde bir okunup tutulur |
| `onboarding_store`, `game_store` | yok | bu kuruluma ait tek bir `bool` |

Son satırı adıyla anmak gerek: o ikisi bilerek **kişiye değil cihaza** ait.
Yeniden kuran biri, tanıtımı atlamaktan çok yeniden görmeyi hak etmiştir.
Cihaz kapsamlı bir tercih yerelde karar verebilir. Sunucu gerçeğinin bir
kopyası veremez — uygulama bir kez, arketipi tutan tercih silindiği için,
sunucuda sonucu dururken insana envanteri yeniden doldurtmaya kalktı.

## Bir isteğin dönüş şekli

Her çağrı `asked()` üzerinden geçer ve `Outcome` olarak döner:

```
Outcome<T> = Ok<T> | Failed<T>(Trouble)

Trouble = Refused(code)   sunucu bilerek hayır dedi, adıyla
        | NotAllowed      403 — uygulamanın açmaması gereken kapı
        | SessionOver      yenilemeden sağ çıkan 401
        | Offline          hiç ulaşmadı
        | Broken           bizim; geçerken loglanır
```

`Trouble` kapalı bir hiyerarşi, yani üzerindeki `switch` bütünlüklü: yeni bir
başarısızlık türü, her ekrana "bu ne demek" diye sorulmadan eklenemez.

**Yerel olan tek tür `Refused`.** Adı, bir ekranın kullanıcıyı görevlere mi
yollayacağını yoksa başka bir e-posta mı isteyeceğini söyleyen şeydir. Geri
kalanı her yerde aynı anlama gelir, o yüzden `TroubleBus`'a düşer ve
sekmelerin üstünde bir kez cevaplanır. Bir reddi ilgilendirmeyen ekran onu
`unhandled()` ile devreder; nereye götürdüğü o zaman birinin yazdığı bir satır
olur, birinin gönderdiği bir dal değil.

## Kelimelerin yaşadığı yer

Bir insanın okuduğu hiçbir şey, satır olarak yazılabiliyorsa Dart'ta yazılmaz.
Kural kitabı `content/README.md`. Günlük metinler, arketipler ve mottolar
içerik paketiyle iner; bir reddin nereye götürdüğü `/v1/effects`'ten iner.
İkisi de dosyaya saklanır, hash ile sürümlenir, ve ikisi de yokken hayatta
kalınabilir — biri bunu söyleyerek, diğeri düz bir cümleye düşerek.

## Pahalıya öğrenilmiş kurallar

- **Başarısız olan ekrana tekrar sorulabilmeli.** `CouldNotLoad` bu sözü
  taşıyor; o yazılana kadar altı kopyası birikmişti.
- **Basılan ve olmayan bir şey bunu söylemeli.** Başarısız eylem için sheet,
  başarısız ekran için yerinde tekrar — sheet kapanınca altında yine
  açıkladığı boş ekran duruyor.
- **Hiçbir teknik ayrıntı ekrana çıkmaz.** Durum kodu bizim sunucumuz hakkında
  bir gerçektir, telefonu tutan kişinin yapabileceği bir şey değil.
- **Maskot router'ın üstünde yaşar.** Geri çağrıları `MaterialApp.builder`
  içinde çalışır, orada ne router ne navigator vardır; tetiklediği hiçbir şey
  `BuildContext` almamalı.
- **Sekme bir kez kurulup canlı tutulur.** Bir sekmenin diğerinde değiştirdiği
  şey bilerek yenilenmeli; `ReloadsOnReturn` üstteki ekranın kapanmasını,
  kabuk ise sekme değişimini ve arka plandan dönmeyi karşılıyor.

## Okuma sırası

Sekiz dosya, her biri bir öncekinin bıraktığı yerden:

```
main.dart
  → features/startup/presentation/startup_page.dart
  → infrastructure/bootstrap/bootstrap_adapter.dart      ← kurallar burada
  → infrastructure/session/device_session.dart
  → features/content/application/content_repository.dart
  → features/shell/presentation/shell_page.dart
  → features/chain/application/chain_cubit.dart → chain_repository.dart
  → infrastructure/api/api_clients.dart + outcome.dart
```
