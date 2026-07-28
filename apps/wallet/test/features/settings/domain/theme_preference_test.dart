import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

void main() {
  group('ThemePreference', () {
    test('every value survives a storage round trip', () {
      for (final preference in ThemePreference.values) {
        expect(
          ThemePreference.fromStorage(preference.storageKey),
          preference,
          reason: 'a stored ${preference.name} came back as something else',
        );
      }
    });

    test('falls back to system for an unknown value', () {
      // What a downgrade would hit: a key written by a newer build.
      expect(ThemePreference.fromStorage('solarized'), ThemePreference.system);
    });

    test('falls back to system when nothing was ever stored', () {
      expect(ThemePreference.fromStorage(null), ThemePreference.system);
    });

    test('storage keys are stable, not derived from the enum name', () {
      // Guards the rename hazard the keys exist to prevent: if these ever
      // change, every user silently loses their choice.
      expect(
        ThemePreference.values.map((p) => p.storageKey),
        ['system', 'light', 'dark'],
      );
    });
  });
}
