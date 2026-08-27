import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the introduction has been seen.
///
/// On the device rather than the server: it is about this installation, not
/// about the person, and someone reinstalling has earned the introduction
/// again more than they have earned skipping it.
@lazySingleton
class OnboardingStore {
  OnboardingStore(this._preferences);

  static const _key = 'onboarding_seen';

  final SharedPreferences _preferences;

  bool get seen => _preferences.getBool(_key) ?? false;

  Future<void> markSeen() => _preferences.setBool(_key, true);
}
