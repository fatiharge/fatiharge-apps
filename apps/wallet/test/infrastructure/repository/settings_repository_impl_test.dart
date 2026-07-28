import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';
import 'package:wallet/infrastructure/repository/settings_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsRepositoryImpl> repositoryWith(
    Map<String, Object> stored,
  ) async {
    SharedPreferences.setMockInitialValues(stored);
    return SettingsRepositoryImpl(await SharedPreferences.getInstance());
  }

  group('SettingsRepositoryImpl', () {
    test('a fresh install follows the system', () async {
      final repository = await repositoryWith({});

      expect(repository.readTheme(), ThemePreference.system);
    });

    test('a written theme reads back', () async {
      final repository = await repositoryWith({});

      await repository.writeTheme(ThemePreference.dark);

      expect(repository.readTheme(), ThemePreference.dark);
    });

    test('survives a restart', () async {
      final first = await repositoryWith({});
      await first.writeTheme(ThemePreference.light);

      // A second instance over the same store — what the next launch sees.
      final second = SettingsRepositoryImpl(
        await SharedPreferences.getInstance(),
      );

      expect(second.readTheme(), ThemePreference.light);
    });

    test('a corrupted value falls back instead of throwing', () async {
      final repository = await repositoryWith({
        SettingsRepositoryImpl.themeKey: 'not-a-theme',
      });

      expect(repository.readTheme(), ThemePreference.system);
    });

    test("does not collide with easy_localization's locale key", () async {
      final repository = await repositoryWith({'locale': 'en'});

      await repository.writeTheme(ThemePreference.dark);
      final preferences = await SharedPreferences.getInstance();

      expect(
        preferences.getString('locale'),
        'en',
        reason: 'writing the theme must not disturb the saved language',
      );
      expect(repository.readTheme(), ThemePreference.dark);
    });
  });
}
