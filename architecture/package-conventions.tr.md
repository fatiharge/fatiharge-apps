# Paket Kuralları

> 🇬🇧 For English: [package-conventions.md](package-conventions.md)

Bu monorepo'da bir paketin nasıl yapılacağı. Yeni bir paket eklerken sıfırdan başlamak yerine en yakın mevcut paketi kopyala.

## Her paket

- `packages/<name>/` altında yaşar (uygulamalar `apps/<name>/` altında).
- Bir Melos workspace member'ıdır: `pubspec.yaml`'ında `resolution: workspace` bulunur ve `<name>`, kök `pubspec.yaml`'daki `workspace:` listesine eklenir.
- Tek satırlık bir `analysis_options.yaml` ile `very_good_analysis` kullanır:
  ```yaml
  include: package:lint_kit/analysis_options.yaml
  ```
- İç detaylar `lib/src/` içinde yaşar; public API tek bir **barrel** `lib/<name>.dart`'tan yeniden export edilir. Paket dışında hiçbir şey doğrudan `src/`'i import etmez.

```
packages/<name>/
├─ pubspec.yaml            # resolution: workspace
├─ analysis_options.yaml   # include: package:lint_kit/analysis_options.yaml
├─ lib/
│  ├─ <name>.dart          # barrel — tek public giriş noktası
│  └─ src/                 # geri kalan her şey (konvansiyonel olarak private)
└─ test/                   # lib/src/ yapısını yansıtır
```

### Barrel örneği

```dart
// lib/ui_kit.dart
library ui_kit;

export 'src/atoms/app_button.dart';
export 'src/theme/app_theme.dart';
// ...yalnızca tüketicilerin görmesi gerekenler.
```

## Feature / domain paketi

Bir feature, tam clean-architecture yığınını taşır. `application/`'ı türlere göre değil, alt-özelliğe (use-case) göre grupla.

Aşağıdaki yerleşim, feature ister `packages/<ad>/lib/src/` içinde olsun ister —çoğunun başlangıçta olduğu gibi— `apps/<app>/lib/features/<ad>/` içinde olsun aynıdır; bkz. [Ne zaman yeni paket açılır](#ne-zaman-yeni-paket-açılır). Değişen tek şey konum.

```
packages/auth/lib/src/
├─ domain/
│  ├─ models/           # freezed varlıklar & value object'ler
│  ├─ repository/       # soyut repository sözleşmeleri
│  ├─ ports/            # dış dünyaya arayüzler (adapter'lar bunları implemente eder)
│  └─ rules/            # saf iş kuralları
├─ application/
│  ├─ login/            # tek use-case için cubit/bloc + state
│  ├─ register/
│  └─ forgot_password/
└─ presentation/
   ├─ page/             # ekranlar (auto_route hedefleri)
   ├─ router/           # bu feature'ın auto_route modülü
   ├─ views/            # birleştirilmiş widget'lar
   └─ validators/       # form validator'ları
```

Paket içi bağımlılık kuralı: `presentation → application → domain`. `domain` Flutter'a özgü hiçbir şey import etmez.

## Kit paketleri

**`ui_kit`** — Atomic Design:

```
packages/ui_kit/lib/src/
├─ atoms/         # en küçük widget'lar (button, text, icon)
├─ molecules/     # küçük kompozisyonlar
├─ organisms/     # daha büyük birleşik bölümler
├─ template/      # sayfa seviyesi iskele
├─ theme/         # renk şemaları + text theme
├─ core/          # paylaşılan widget altyapısı
├─ constant/
├─ extensions/
└─ side_effect/   # toast, dialog, haptik
```

**`utility_kit`** — framework'ten bağımsız, **bağımlılık-hafif** yardımcılar. Minimal tut: kodu ancak gerçek bir tüketici ihtiyaç duyunca ekle ve ağır bağımlılıkları dışarıda bırak — UI/layout yardımcıları `ui_kit`'e, güvenli storage/kripto bir `storage_kit`'e, localization loader'ları kendi l10n paketine ait.

```
packages/utility_kit/lib/src/
└─ base/          # UI-bağımsız base sözleşmeler (örn. EffectBloc)
```

**`lint_kit`** — paylaşılan analyzer config'ini `lib/analysis_options.yaml`'da sunar (`very_good_analysis` tabanlı). Bir `dev_dependency`'dir ve diğer her paketin `analysis_options.yaml`'ı tarafından referans alınır.

## Uygulama (composition root)

Uygulama incedir: adapter'ları port'lara bağlar ve feature giriş noktalarını barındırır.

```
apps/<app>/lib/
├─ main.dart               # tek giriş noktası — flavor'lar native projelerde yaşar
├─ app.dart                # kök widget: theme, lokalizasyon, router
├─ config/
│  ├─ injectable.dart / injectable.config.dart   # get_it + injectable
│  ├─ modules/             # DI modülleri
│  ├─ env.dart             # build-time anahtarlar (String.fromEnvironment)
│  └─ app_crash_listener.dart
├─ infrastructure/         # DIŞ KENAR — domain port/repository'lerini implemente eder
│  ├─ adapter/             # port adapter'ları (örn. bootstrap)
│  ├─ repository/          # *_repository_impl.dart + dto/ + mapper/
│  ├─ storage/             # somut veritabanı
│  ├─ seed/                # her kurulumun ilk açılışta aldığı veri
│  └─ dev/                 # --dart-define arkasındaki araçlar, yayınlanmaz
├─ route/                  # app_router feature router'larını birleştirir
├─ theme/                  # uygulama seviyesi theme bağlama
├─ features/<ad>/          # domain / application / presentation
└─ generated/              # kod üretimi çıktısı, elle düzenlenmez
```

`lib/` altında **`app/` diye bir sarmalayıcı klasör yok**. Paketlerin
`lib/src/`'e ihtiyacı var çünkü public API'yi iç detaydan ayırır; bir
uygulamanın dış tüketicisi olmadığı için aynı iç içelik hiçbir bilgi taşımaz,
karşılığında her import'ta bir seviye maliyeti çıkarır.

Backend geldiğinde bunlara `infrastructure/mocks/`, `infrastructure/push/`,
`network/` ve `remote_config/` eklenir. Henüz var olmadıkları için mevcut
gibi listelenmiyorlar.

Kilit nokta: **somut adapter'ları yalnızca uygulama bilir.** Feature'lar port ve repository sözleşmelerini bildirir; `infrastructure/` bunları implemente eder ve DI (`config/`) implementasyon → arayüz bağlar.

## İsimlendirme

- Paket adları: `snake_case`, dizinle eşleşir (`ui_kit`, `utility_kit`, `content_engine`).
- Kit'ler `_kit` ile biter. Feature paketleri özelliğe göre adlanır (`auth`, `dynamic_form`).
- Dart dosyaları: `snake_case.dart`. Sınıflar: `PascalCase`. Dosya başına bir birincil public tip.

## Test

- Testler `test/`'te yaşar, `lib/src/` yapısını yansıtır.
- `domain` ve `application`'ı (saf, hızlı) yoğun test etmeyi tercih et; `presentation`'ı değdiği yerde widget-test et.
- `melos run test`, `test/` dizini olan her paketi çalıştırır.

## Dokümantasyon

Elle yazılan dokümanı yavaş değişen seviyede tut; geri kalan her şeyi ürettir. Anti-drift stratejisinin tamamı budur — bir aracın zaten ürettiği şeyi elle sürdürme.

- **Paket `README.md` (+ `README.tr.md`)** — ince ve **sabit**: paket ne işe yarar, tek kısa kullanım örneği, `CHANGELOG.md` ve `architecture/`'a linkler. Bu bir changelog *değildir*; yalnızca public API değişince dokun. Repo'nun geri kalanı gibi iki dilli: üstte çapraz-link başlığıyla `.md` / `.tr.md` çiftini birlikte tut. İnce tutmak, iki dosyanın bakımını ucuz tutan şeydir.
- **`CHANGELOG.md`** — `melos version` tarafından Conventional Commits'ten üretilir. **Asla elle düzenleme.** Değişim geçmişin commit'lerindir.
- **API referansı** — `lib/src/**` içindeki `///` doc-comment'lerden gelir, `dart doc` ile üretilir. Public tipleri ve üyeleri belgele; yorum kodun yanında yaşadığı için drift edemez.
- **Kök README** — paketleri listelemez; `packages/`'a işaret eder. Dizinin kendisi index'tir, senkronlanacak bir şey yoktur.

## Ne zaman yeni paket açılır

Kod **feature/uygulamalar arasında yeniden kullanılıyorsa**, **bağımsız bir yaşam döngüsü/versiyonlama** gerekiyorsa ya da **zorlanan bir sınırdan** faydalanıyorsa (feature A'nın feature B'nin iç detayına uzanmasını derleyicinin durdurmasını istiyorsan) paket oluştur. Aksi halde mevcut bir paket içinde bir klasör yeterlidir — fazla parçalama.

Özellikle **feature** için: uygulamanın içinde başlar ve ikinci bir uygulama ya da feature ihtiyaç duyduğunda `packages/`'a taşınır. Tek tüketici bu ölçütü geçmez; paketi erken açmak, bakımı gereken bir pubspec, barrel, changelog ve versiyon karşılığında yalnızca bir import sınırı satın alır.

## Yeni paket için kontrol listesi

1. `pubspec.yaml` (`resolution: workspace`), barrel `lib/<name>.dart`, tek satırlık `analysis_options.yaml` ve ince `README.md` + `README.tr.md` içeren `packages/<name>/`.
2. `<name>`'i kök `pubspec.yaml`'daki `workspace:` listesine ekle.
3. `melos bootstrap`, ardından `melos run analyze` ve `melos run test`.
4. `feature/*` veya `chore/*` branch'inde Conventional Commit ile commit'le.
