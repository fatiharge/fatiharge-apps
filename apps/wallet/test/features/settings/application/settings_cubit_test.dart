import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet/features/settings/application/settings_cubit.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

void main() {
  late _MockSettingsRepository repository;

  // mocktail needs a stand-in before `any()` can match a non-nullable enum.
  setUpAll(() => registerFallbackValue(ThemePreference.system));

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.readTheme()).thenReturn(ThemePreference.system);
    when(() => repository.writeTheme(any())).thenAnswer((_) async {});
  });

  group('SettingsCubit', () {
    test('starts from what the repository already has', () {
      when(() => repository.readTheme()).thenReturn(ThemePreference.dark);

      expect(SettingsCubit(repository).state, ThemePreference.dark);
    });

    blocTest<SettingsCubit, ThemePreference>(
      'emits the newly chosen theme',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.selectTheme(ThemePreference.dark),
      expect: () => [ThemePreference.dark],
    );

    blocTest<SettingsCubit, ThemePreference>(
      'writes the choice through',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.selectTheme(ThemePreference.light),
      verify: (_) =>
          verify(() => repository.writeTheme(ThemePreference.light)).called(1),
    );

    blocTest<SettingsCubit, ThemePreference>(
      'ignores a re-selection of the current theme',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.selectTheme(ThemePreference.system),
      expect: () => <ThemePreference>[],
      verify: (_) => verifyNever(() => repository.writeTheme(any())),
    );

    blocTest<SettingsCubit, ThemePreference>(
      'keeps the new theme even when the write fails',
      build: () {
        when(
          () => repository.writeTheme(any()),
        ).thenThrow(Exception('disk full'));
        return SettingsCubit(repository);
      },
      act: (cubit) async {
        // The throw escapes selectTheme; what matters is that the state the
        // user asked for already landed before it did.
        await cubit.selectTheme(ThemePreference.dark).catchError((_) {});
      },
      expect: () => [ThemePreference.dark],
    );
  });
}

class _MockSettingsRepository extends Mock implements SettingsRepository {}
