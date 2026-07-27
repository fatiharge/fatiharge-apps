# Bağımlılık Enjeksiyonu (DI)

> 🇬🇧 For English: [dependency-injection.md](dependency-injection.md)

Service locator olarak **`get_it`**, kayıtlarını üretmek için **`injectable`** kullanıyoruz. Hexagonal mimari burada bağlanır: uygulama, feature/domain paketlerinin bildirdiği **port**'lara somut **adapter**'ları bağlar (bkz. [overview.tr.md](overview.tr.md)).

## DI nerede yaşar

Somut implementasyonları yalnızca **uygulama** (composition root) bilir. Kayıt `apps/<app>/lib/config/` altında yaşar:

```
config/
├─ injectable.dart          # configureDependencies() giriş noktası
├─ injectable.config.dart   # GENERATED — düzenleme
└─ modules/
   ├─ core_module.dart      # üçüncü parti singleton'lar (http, storage, …)
   ├─ api_module.dart       # API client / networking bağlama
   └─ environments.dart     # ortam (flavor) sabitleri
```

## Katmanlara nasıl oturur

- **domain** bir `port` ya da repository *arayüzü* bildirir.
- **application** o arayüze bağımlıdır (constructor injection), asla somut sınıfa değil.
- **app/infrastructure** `*_impl` adapter'ını sağlar ve onu annotate eder ki `injectable` arayüze bağlasın.

```dart
// domain (bir feature paketinde) — sözleşme
abstract class AuthRepository {
  Future<Session> login(String email, String password);
}

// app/infrastructure — adapter, arayüze bağlı
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);
  final AuthApi _api;
  // ...
}
```

## Kayıt annotation'ları

| Annotation                 | Ne için                                              |
| -------------------------- | ---------------------------------------------------- |
| `@injectable`              | Her resolve'da yeni örnek                            |
| `@lazySingleton`           | Tek örnek, ilk kullanımda oluşur (varsayılan tercih) |
| `@singleton`               | Tek örnek, kayıtta oluşur                            |
| `@LazySingleton(as: Port)` | Bir implementasyonu arayüzüne/port'una bağla         |
| `@module`                  | Sahip olmadığın üçüncü parti tipleri sağla (`modules/`) |

### Modül ile üçüncü parti tipler

```dart
@module
abstract class CoreModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
```

## Giriş noktası

```dart
// injectable.dart
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

final getIt = GetIt.instance;
```

Uygulama bootstrap'ında, `runApp`'ten önce bir kez çağrılır. Tüketiciler `getIt<AuthRepository>()` ile resolve eder — widget'lar içinse `getIt`'ten sağlanan bloc/cubit üzerinden.

## Ortamlar (flavor'lar)

Flavor'a göre implementasyon değiştirmek için `injectable` ortamlarını kullan — örn. gerçek API vs mock:

```dart
@LazySingleton(as: AuthApi, env: [Environment.dev])
class AuthApiMock implements AuthApi { /* ... */ }

@LazySingleton(as: AuthApi, env: [Environment.prod])
class AuthApiHttp implements AuthApi { /* ... */ }
```

Ortamı `configureDependencies`'te aktif flavor'a göre seç. Mock'lar (`app/infrastructure/mocks/`) `dev` build'lerinin canlı backend olmadan çalışmasını sağlar.

## Kurallar

- **Arayüzlere bağımlı ol, implementasyonlara değil.** Constructor'lar port alır; DI adapter sağlar.
- **Somutları yalnızca uygulama kaydeder.** Paketler `get_it`'ten habersiz kalır.
- **Annotation değiştirince yeniden üret:** `melos run generate` (ya da `dart run build_runner build --delete-conflicting-outputs`). `injectable.config.dart` commit'lenir ama elle düzenlenmez.
