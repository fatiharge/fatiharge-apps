import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the mascot is on screen at all.
///
/// A notifier rather than a plain read: the switch is in settings and the
/// mascot lives above the router, so the two have no way to talk except
/// through something both can hold.
@lazySingleton
class MascotStore {
  MascotStore(this._preferences)
    : visible = ValueNotifier(_preferences.getBool(_key) ?? true);

  static const _key = 'mascot_visible';

  final SharedPreferences _preferences;

  final ValueNotifier<bool> visible;

  Future<void> setVisible({required bool value}) async {
    visible.value = value;
    await _preferences.setBool(_key, value);
  }
}
