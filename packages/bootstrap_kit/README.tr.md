# bootstrap

> 🇬🇧 For English: [README.md](README.md)

Fatiharge monorepo'su için uygulama başlatma orkestrasyonu: guarded bir crash
boundary ve retry'lı bir başlatma-job motoru. Presentation (splash view,
routing) app tarafında kalır ve `BootstrapPort` üzerinden sağlanır.

Barrel'ı import et; `src/`'e doğrudan uzanma:

```dart
import 'package:bootstrap_kit/bootstrap_kit.dart';
```

## İçerik

### `CrashListener`

En dıştaki başlatma sınırı: app'i guarded bir zone içinde çalıştırır, framework
ve yakalanmamış async hatalarını `onCrash`'e iletir. `onCrash`'i app'te
implemente et (örn. Crashlytics'e raporla).

```dart
class AppCrashListener extends CrashListener {
  @override
  Future<void> onCrash({required Object error, StackTrace? stack, required bool fatal}) async {
    // crash backend'ine raporla
  }
}

void main() => AppCrashListener().runGuarded(() async {
  // configureDependencies(); runApp(...);
});
```

### `BootstrapCubit` + `BootstrapPort` + `BootstrapJob`

Sıralı başlatma job'larını çalıştırır; her biri kendi retry'ı, hata politikası
(`skip` / `retry` / `restart`) ve opsiyonel `fallback`'iyle. İlerleme yayınlar,
kurtarılabilir bir hatada durur. App `BootstrapPort`'u implemente eder.

```dart
class AppBootstrapPort extends BootstrapPort {
  @override
  List<BootstrapJob> jobs() => [
        BootstrapJob('remote-config', fetchRemoteConfig, retries: 2),
        BootstrapJob('warm-cache', warmCache, errorPolicy: BootstrapErrorPolicy.skip),
      ];

  @override
  Widget get bootstrapView => const SplashPage();

  @override
  void bootstrapFinished() => router.replaceAll([const HomeRoute()]);
}
```

## Dokümantasyon

- API referansı: `lib/src/**` içindeki doc-comment'ler (`dart doc` ile üretilir).
- Değişim geçmişi: [`CHANGELOG.md`](CHANGELOG.md) — Conventional Commits'ten
  `melos version` ile üretilir; elle düzenleme.
- Tasarım gerekçesi: repo kökündeki [`architecture/`](../../architecture).
