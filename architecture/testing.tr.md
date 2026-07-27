# Test

> 🇬🇧 For English: [testing.md](testing.md)

Bu monorepo'da nasıl test ediyoruz. [overview.tr.md](overview.tr.md)'deki katmanlama büyük ölçüde testi ucuzlatmak için var: saf `domain` ve `application` kodu Flutter ya da IO gerektirmez.

## Neyi nerede test ederiz

| Katman           | Test türü                | Hedef                                      |
| ---------------- | ------------------------ | ------------------------------------------ |
| `domain`         | Saf unit test            | Yüksek kapsam — kurallar, modeller, mapper'lar |
| `application`    | Cubit/bloc testi         | Her state geçişi & yan etki                |
| `presentation`   | Widget testi             | Kilit ekranlar, kritik widget'lar, golden-değer UI |
| adapter'lar (app)| Integration/contract     | Port implementasyonları fake/mock'a karşı  |

Mantığı `domain`/`application`'a **aşağı** it; böylece testlerin çoğu hızlı saf-Dart testleri olur. Widget testleri değerli ama yavaştır — onları değdikleri yerde harca.

## Araçlar

| Amaç               | Paket                                     |
| ------------------ | ----------------------------------------- |
| Test runner        | `flutter_test`                            |
| Bloc/cubit testi   | `bloc_test`                               |
| Mock / fake        | `mocktail` (codegen yok, null-safe)       |
| Matcher'lar        | yerleşik + `flutter_test` matcher'ları    |

> `mockito` yerine `mocktail`'i tercih et — build_runner adımı yok. **Port/repository**'leri (arayüzleri) mock'la, asla somut adapter'ları değil.

## Yerleşim

Testler her paketin `test/`'inde yaşar, `lib/src/`'i yansıtır:

```
packages/auth/
├─ lib/src/application/login/login_cubit.dart
└─ test/application/login/login_cubit_test.dart
```

## Kurallar

- `test` başına bir davranış; birimi `group('LoginCubit', …)` ile grupla.
- Arrange–Act–Assert; testleri beklenen davranışa göre adlandır ("… olduğunda [loading, success] yayar").
- Cubit/bloc için `blocTest`'i açık `build`, `act`, `expect` ile kullan.
- Fake'ler domain **port**'larını implemente eder; onları `test/`'te tut (veya ortak `test/fakes/`).
- Testlerde network, gerçek storage, `DateTime.now()` yok — clock/port'ları enjekte et.

### Örnek — cubit testi

```dart
void main() {
  late LoginRepository repository; // bir domain port'u

  setUp(() => repository = _MockLoginRepository());

  blocTest<LoginCubit, LoginState>(
    'kimlik bilgileri geçerliyken [loading, success] yayar',
    build: () {
      when(() => repository.login(any(), any()))
          .thenAnswer((_) async => const Session(token: 't'));
      return LoginCubit(repository);
    },
    act: (cubit) => cubit.submit('a@b.c', 'pw'),
    expect: () => const [LoginState.loading(), LoginState.success()],
  );
}

class _MockLoginRepository extends Mock implements LoginRepository {}
```

## Çalıştırma

```bash
melos run test        # test/ dizini olan her paket
melos run coverage    # aynısı, --coverage ile (paket başına coverage/lcov.info yazar)
```

CI her PR'da `melos run test` çalıştırır (bkz. `.github/workflows/ci.yml`). Davranışı değiştiren bir değişiklik testleriyle birlikte gelmeli.

## Coverage

- Yerelde `melos run coverage` ile üret; `coverage/lcov.info`'yu birleştir/incele.
- `flutter test --coverage` yalnızca testlerin import ettiği kütüphaneleri
  enstrümante eder; testi olmayan dosya raporda %0 olarak değil, **hiç**
  görünmez — bu da oranı sessizce şişirir. `test/coverage_helper_test.dart`
  her kütüphaneyi import ederek bunu engeller; `melos run coverage:helper` ile
  yeniden üretilir. Yeni bir kütüphane eklenip helper güncellenmezse test
  kırılır, yani oran tekrar yanıltıcı hale gelemez.
- Raporu `genhtml coverage/lcov.info -o coverage/html` ile oku (`brew install
  lcov` gerekir) ya da `lcov.info`'yu satır içinde gösteren bir editör
  eklentisi kullan.
- `domain`/`application`'da yükseği hedefle; generated ya da presentation tutkalında %100 kovalama.
- Generated dosyaları hariç tut (zaten `lint_kit` ile analizden hariç).
