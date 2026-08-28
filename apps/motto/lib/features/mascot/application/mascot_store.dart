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

  /// Held down by a screen that needs the space, and released when it leaves.
  /// Separate from [visible] because one is a preference and the other is a
  /// screen saying "not here": a screen must not be able to change what
  /// somebody chose in settings.
  final ValueNotifier<int> suppressions = ValueNotifier(0);

  /// Whether it should be on screen right now.
  ValueNotifier<bool> get onScreen => _onScreen;

  late final ValueNotifier<bool> _onScreen = _combined();

  ValueNotifier<bool> _combined() {
    final result = ValueNotifier(visible.value && suppressions.value == 0);
    void update() => result.value = visible.value && suppressions.value == 0;
    visible.addListener(update);
    suppressions.addListener(update);
    return result;
  }

  /// Counted rather than flagged: a sheet over a suppressed screen would
  /// otherwise release the suppression when it closed.
  void suppress() => suppressions.value++;

  void release() {
    if (suppressions.value > 0) suppressions.value--;
  }

  Future<void> setVisible({required bool value}) async {
    visible.value = value;
    await _preferences.setBool(_key, value);
  }
}
