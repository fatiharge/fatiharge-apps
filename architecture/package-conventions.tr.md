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

Bir feature paketi, tam clean-architecture yığınını taşır. `application/`'ı türlere göre değil, alt-özelliğe (use-case) göre grupla.

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

**`utility_kit`** — framework'ten bağımsız yardımcılar:

```
packages/utility_kit/lib/src/
├─ base/          # base sınıflar (örn. base cubit/state, failure)
├─ exception/
├─ extension/
├─ localization/
├─ service/
├─ storage/
└─ util/
```

**`lint_kit`** — paylaşılan analyzer config'ini `lib/analysis_options.yaml`'da sunar (`very_good_analysis` tabanlı). Bir `dev_dependency`'dir ve diğer her paketin `analysis_options.yaml`'ı tarafından referans alınır.

## Uygulama (composition root)

Uygulama incedir: adapter'ları port'lara bağlar ve feature giriş noktalarını barındırır.

```
apps/<app>/lib/
├─ main.dart
└─ app/
   ├─ app.dart
   ├─ config/
   │  ├─ injectable.dart / injectable.config.dart   # get_it + injectable
   │  ├─ modules/            # DI modülleri (api_module, core_module, environments)
   │  ├─ env.dart
   │  ├─ app_log.dart
   │  └─ app_crash_listener.dart
   ├─ infrastructure/        # DIŞ KENAR — domain port/repository'lerini implemente eder
   │  ├─ adapter/            # port adapter'ları
   │  ├─ repository/         # *_repository_impl.dart
   │  ├─ mocks/              # dev/test flavor'ları için API mock'ları
   │  └─ push/               # push notification servisi
   ├─ network/               # interceptor http client
   ├─ remote_config/         # accessor / mapper / model
   ├─ route/                 # app_router feature router'larını birleştirir
   ├─ theme/                 # uygulama seviyesi theme bağlama (ui_kit kullanır)
   └─ features/<f>/presentation/{page,router}   # ince feature kabukları
```

Kilit nokta: **somut adapter'ları yalnızca uygulama bilir.** Feature/domain paketleri port bildirir; `app/infrastructure/` bunları implemente eder ve DI (`config/modules/`) implementasyon → arayüz bağlar.

## İsimlendirme

- Paket adları: `snake_case`, dizinle eşleşir (`ui_kit`, `utility_kit`, `content_engine`).
- Kit'ler `_kit` ile biter. Feature paketleri özelliğe göre adlanır (`auth`, `dynamic_form`).
- Dart dosyaları: `snake_case.dart`. Sınıflar: `PascalCase`. Dosya başına bir birincil public tip.

## Test

- Testler `test/`'te yaşar, `lib/src/` yapısını yansıtır.
- `domain` ve `application`'ı (saf, hızlı) yoğun test etmeyi tercih et; `presentation`'ı değdiği yerde widget-test et.
- `melos run test`, `test/` dizini olan her paketi çalıştırır.

## Ne zaman yeni paket açılır

Kod **feature/uygulamalar arasında yeniden kullanılıyorsa**, **bağımsız bir yaşam döngüsü/versiyonlama** gerekiyorsa ya da **zorlanan bir sınırdan** faydalanıyorsa (feature A'nın feature B'nin iç detayına uzanmasını derleyicinin durdurmasını istiyorsan) paket oluştur. Aksi halde mevcut bir paket içinde bir klasör yeterlidir — fazla parçalama.

## Yeni paket için kontrol listesi

1. `pubspec.yaml` (`resolution: workspace`), barrel `lib/<name>.dart`, tek satırlık `analysis_options.yaml` içeren `packages/<name>/`.
2. `<name>`'i kök `pubspec.yaml`'daki `workspace:` listesine ekle.
3. `melos bootstrap`, ardından `melos run analyze` ve `melos run test`.
4. `feature/*` veya `chore/*` branch'inde Conventional Commit ile commit'le.
