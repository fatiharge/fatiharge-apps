/// [system] is a standing instruction, not a resolved value: collapsing it at
/// write time would pin the app to whatever the device was that evening. Not
/// `ThemeMode`, because this is `domain`.
enum ThemePreference {
  system,
  light,
  dark;

  /// Spelled out rather than [name]: a rename must not orphan saved values.
  String get storageKey => switch (this) {
    ThemePreference.system => 'system',
    ThemePreference.light => 'light',
    ThemePreference.dark => 'dark',
  };

  /// Anything unrecognised falls back to [system] — a newer version's value,
  /// or a corrupted store.
  static ThemePreference fromStorage(String? value) => values.firstWhere(
    (preference) => preference.storageKey == value,
    orElse: () => ThemePreference.system,
  );
}
