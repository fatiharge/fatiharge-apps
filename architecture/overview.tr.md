# Mimari Genel Bakış

> 🇬🇧 For English: [overview.md](overview.md)

## Hedefler

- **Modüler** — özellikler ve ortak sorumluluklar; izole biçimde derlenebilen, test edilebilen ve akıl yürütülebilen bağımsız paketlerde yaşar.
- **Test edilebilir** — iş mantığı, Flutter/IO bağımlılığı olmayan saf Dart'tır ve arayüzlerin (port'ların) arkasına gizlenir.
- **Tutarlı** — her paket aynı yerleşimi ve aynı tech stack'i izler; böylece herhangi bir geliştirici herhangi bir pakette gezinebilir.
- **Otomatikleştirilebilir** — Conventional Commits + Melos versiyonlama ve changelog'u besler; tek bir lint config tüm repoyu yönetir.

## İlkeler

### 1. Clean Architecture + Hexagonal (ports & adapters)

Kod, katı bir **bağımlılık kuralı** ile üç katmana ayrılır: bağımlılıklar *içeriye* bakar, asla dışarıya değil.

```
presentation  ──▶  application  ──▶  domain
     (UI)          (state / use-case)   (saf iş çekirdeği)
```

- **domain** — saf Dart. Varlıklar/modeller (`freezed`), repository sözleşmeleri, iş kuralları ve dış dünyaya açılan **port'lar** (arayüzler). Flutter'a özgü hiçbir şeye bağlı değildir.
- **application** — use-case'leri düzenler ve UI'a bakan state'i (`bloc`/`cubit`) tutar. Yalnızca `domain`'e bağlıdır.
- **presentation** — widget'lar, sayfalar, router'lar, validator'lar. `application` + `domain`'e bağlıdır.

Port'ların ve repository'lerin somut implementasyonları (HTTP client, storage, push, mock'lar) **adapter**'lardır ve uygulamanın composition root'unda bağlanır — bkz. [Bağımlılık yönü](#bağımlılık-yönü). Hexagonal "ports & adapters" fikri budur: çekirdek *neye* ihtiyaç duyduğunu tanımlar; dıştaki uygulama *nasıl* sağlanacağını verir.

### 2. Feature-first uygulama kabuğu

Uygulama ince bir **composition root**'tur. Bağımlılıkları bağlar ve feature giriş noktalarını barındırır; ağır mantık feature'ların `domain`/`application` katmanlarında yaşar — bu katmanlar ister app içinde ister ayrı bir pakette olsun.

### 3. UI'da Atomic Design

Paylaşılan `ui_kit`; `atoms → molecules → organisms → templates` ve enine kesen `core / constant / extensions` olarak düzenlenir.

### 4. Varsayılan Cubit, efekt varsa Bloc

Application katmanındaki state tutucular **cubit**'tir — ekran ayrıca tek seferlik bir şey *yapmak* zorunda değilse: snackbar göstermek, platforma bir diyalog devretmek, yönlendirmek. State neyin çizileceğini anlatır; state'e konan bir eylem her rebuild'de yeniden tetiklenir.

Tek atımlık eylemler efekt kanalından geçer; `utility_kit` bunu `EffectBloc<Event, State, Effect>` olarak sunar. O sınıf `Bloc`'u extend ettiği için **cubit'i bloc'a çeviren şey efekt ihtiyacıdır** — metot sayısı değil.

| Ekran yalnızca state'ten çiziliyor        | `Cubit<State>`                     |
| ----------------------------------------- | ---------------------------------- |
| Ekran ayrıca tek atımlık eylem tetikliyor | `EffectBloc<Event, State, Effect>` |

Yani soru ekranın ne kadar iş yaptığı değil, yaptıklarından birinin *bir kez* olup olmadığıdır: satırın kaybolması state, ona eşlik eden geri-al snackbar'ı efekttir — ve tipi belirleyen snackbar'dır.

İki şey yapılmaz: kuralı atlatmak için cubit'e kendi `StreamController`'ını koymak, ya da kanalı `Cubit`'e taşımak için `utility_kit`'i genişletmek. Tek mekanizma, tek yer.

## Monorepo yerleşimi

```
fatiharge-apps/
├─ apps/                     # çalıştırılabilir uygulamalar (ince composition root'lar)
│  └─ wallet/lib/            # config, route, theme, infrastructure, features/
├─ packages/                 # paylaşılan paketler (Melos workspace member)
│  ├─ lint_kit/              # ortak analyzer + lint config (very_good_analysis)
│  ├─ utility_kit/           # UI'dan bağımsız temel sözleşmeler (EffectBloc)
│  ├─ bootstrap_kit/         # uygulama başlangıç orkestrasyonu (job, cubit, page)
│  └─ …                      # ui_kit, api_client, paylaşılan feature'lar — aşağıda
├─ architecture/             # bu dokümanlar
└─ .githooks/ .github/       # governance (commit hook, CI)
```

`ui_kit` ve `api_client` hedeflenen yapının parçası ama **henüz yoklar**.
Burada hedefi netleştirmek için anılıyorlar, mevcut oldukları anlamına gelmez.

### Bir feature nerede yaşar

Bir feature, **uygulamanın içinde** bir klasör olarak başlar
(`apps/<app>/lib/features/<ad>/`) ve aşağıda anlatılan
`domain / application / presentation` katmanlamasını aynen taşır.
`packages/<ad>/` altına ancak ikinci bir uygulama ya da feature gerçekten
ihtiyaç duyduğunda çıkar — ölçüt
[package-conventions.tr.md](package-conventions.tr.md#ne-zaman-yeni-paket-açılır)
içinde ve "tek tüketici" bu ölçütü geçmez.

Nerede yaşarsa yaşasın aynı kurallar geçerli:

- `domain/` ve `application/` feature'ın dışında hiçbir şeye bakmaz.
- `presentation/` barındıran uygulamanın lokalizasyonunu, DI'ını, router'ını ve
  temasını kullanabilir.
- **Adapter'lar hiçbir zaman feature'ın içinde olmaz.** Feature repository
  sözleşmesini bildirir; uygulama implemente eder ve ikinci bir uygulama onları
  farklı biçimde implemente etmekte serbesttir.

### Paket taksonomisi

| Tür         | Örnekler                                   | Katman içerir mi?                        |
| ----------- | ------------------------------------------ | ---------------------------------------- |
| **kit**     | `ui_kit`, `utility_kit`, `lint_kit`        | Hayır — enine kesen yapı taşları         |
| **generated** | `api_client`                             | Hayır — kod üretimi, elle düzenlenmez    |
| **feature** | `apps/<app>/lib/features/<ad>/`, paylaşılınca `packages/<ad>/` | Evet — `domain / application / presentation` |
| **app**     | `apps/<app>`                               | Composition root + `features/` kabuğu    |

## Bağımlılık yönü

İzin verilen bağımlılık kenarları (ok "bağımlı olabilir" demek):

```mermaid
graph TD
  app[apps/*] --> feature[feature'lar<br/>app içinde ya da paket]
  app --> uikit[ui_kit]
  app --> util[utility_kit]
  app --> api[api_client]
  app --> boot[bootstrap_kit]
  feature --> uikit
  feature --> util
  feature --> api
  uikit --> util
  boot --> util
  subgraph "her şey (dev) buna bağlı"
    lint[lint_kit]
  end
```

Kurallar:

- **domain** katmanları kendi paketleri dışında hiçbir şeye bağlı değildir (`utility_kit` saf yardımcıları ve saf paketler hariç).
- **Bir feature uygulamanın içinde başlar** ve ancak ikinci bir tüketici çıkınca paket olur. Katmanlama her iki durumda da aynıdır.
- **Feature'lar başka feature'lara bağlanmaz.** Ortak kod bir kit'e taşınır; feature'lar arası akışları uygulama koordine eder.
- **Somut adapter'ları yalnızca uygulama bilir.** Port/repository'leri (`infrastructure/`) uygulama implemente eder ve DI ile kaydeder.
- **Döngü yok.** Melos/pub bir bağımlılık döngüsünü reddeder; yukarıdaki katmanlama bunu tasarımca engeller.

## Tech stack (standart)

| Konu               | Seçim                                     |
| ------------------ | ----------------------------------------- |
| State yönetimi     | `flutter_bloc` (cubit / bloc)             |
| Dependency injection | `get_it` + `injectable`                 |
| Routing            | `auto_route` (feature başına router, uygulamada birleştirilir) |
| Model / union      | `freezed` (+ `freezed_annotation`)        |
| Lokalizasyon       | `easy_localization` (+ generated locale key) |
| Asset'ler          | `flutter_gen`                             |
| Flavor             | `flutter_flavorizr`                       |
| API client         | generated OpenAPI (`api_client`)          |
| Networking         | interceptor client arkasında `http`       |
| Lint               | `lint_kit` üzerinden `very_good_analysis` |
| Crash / messaging  | Firebase (`core`, `crashlytics`, `messaging`) |

## Kod üretimi

Üretilen dosyalar **commit edilir** ama asla elle düzenlenmez ve analizden hariç tutulur (bkz. `lint_kit`):

| Generator             | Çıktı deseni          |
| --------------------- | --------------------- |
| `freezed`             | `*.freezed.dart`      |
| `json_serializable`   | `*.g.dart`            |
| `auto_route_generator`| `*.gr.dart`           |
| `injectable_generator`| `*.config.dart`       |
| `flutter_gen`         | `**/generated/**`     |

Üretimi ilgili pakette `dart run build_runner build --delete-conflicting-outputs` ile çalıştır.

---

Her paket türünün somut klasör yerleşimi için bkz. **[package-conventions.tr.md](package-conventions.tr.md)**.
