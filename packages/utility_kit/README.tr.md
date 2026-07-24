# utility_kit

> 🇬🇧 For English: [README.md](README.md)

Fatiharge monorepo'sunda paylaşılan, framework seviyesinde ve UI'dan bağımsız
yardımcılar. Bu paketi **bağımlılık-hafif** tut — UI, storage, kripto ve
localization yardımcıları kendi kit'lerine ait.

Barrel'ı import et; `src/`'e doğrudan uzanma:

```dart
import 'package:utility_kit/utility_kit.dart';
```

## İçerik

### `EffectBloc<Event, State, Effect>`

State akışından ayrı bir kanalda tek-seferlik yan etkiler (navigation, snackbar,
toast, …) yayan bir `Bloc`. State *ne render edileceğini* tanımlar; bir effect
ise *bir kez yapılacak bir şeyi* tanımlar.

```dart
class LoginBloc extends EffectBloc<LoginEvent, LoginState, LoginEffect> {
  LoginBloc() : super(const LoginState.initial()) {
    on<Submitted>((event, emit) async {
      // ... başarılı olunca:
      emitEffect(const LoginEffect.navigateHome());
    });
  }
}

// Presentation katmanında tek-seferlik işleme için `bloc.effects`'i dinle.
```

## Dokümantasyon

- API referansı: `lib/src/**` içindeki doc-comment'ler (`dart doc` ile üretilir).
- Değişim geçmişi: [`CHANGELOG.md`](CHANGELOG.md) — Conventional Commits'ten
  `melos version` ile üretilir; elle düzenleme.
- Tasarım gerekçesi: repo kökündeki [`architecture/`](../../architecture).
