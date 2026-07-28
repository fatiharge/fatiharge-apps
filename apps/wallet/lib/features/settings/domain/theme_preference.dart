/// What the user chose in settings — not what is on screen.
///
/// [system] is a standing instruction ("follow the device"), not a resolved
/// value, so it has to survive storage as itself. Collapsing it to light or
/// dark at write time would silently pin the app to whatever the device
/// happened to be that evening.
///
/// Deliberately not Flutter's `ThemeMode`, though it mirrors it: this is
/// `domain`, and the mapping to a widget-layer type belongs in presentation.
enum ThemePreference {
  system,
  light,
  dark;

  /// The stored form. Spelled out rather than using [name] so that renaming a
  /// constant cannot silently orphan everyone's saved preference.
  String get storageKey => switch (this) {
    ThemePreference.system => 'system',
    ThemePreference.light => 'light',
    ThemePreference.dark => 'dark',
  };

  /// Reads [storageKey] back, falling back to [system] for anything
  /// unrecognised — a value written by a newer version, or a corrupted store.
  static ThemePreference fromStorage(String? value) => values.firstWhere(
    (preference) => preference.storageKey == value,
    orElse: () => ThemePreference.system,
  );
}
