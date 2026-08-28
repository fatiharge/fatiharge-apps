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

  /// The routes the mascot stays off.
  ///
  /// Read from the route rather than counted by a widget that wraps the page.
  /// The counting version was right in a test and wrong on a phone: whether a
  /// wrapper's `initState` and `dispose` pair up depends on how the router
  /// builds and keeps pages, and the mascot sat on the result screen's buttons
  /// because of it. Which screen is up is a fact the router already has.
  static const closedTo = {
    'QuestionRoute',
    'CalculatingRoute',
    'ResultRoute',
    'ShareCardRoute',
  };

  /// Set from the router. Separate from [visible] because one is a preference
  /// and the other is a screen saying "not here": a screen must not be able to
  /// change what somebody chose in settings.
  final ValueNotifier<bool> allowedHere = ValueNotifier(true);

  /// Whether it should be on screen right now.
  ValueNotifier<bool> get onScreen => _onScreen;

  late final ValueNotifier<bool> _onScreen = _combined();

  ValueNotifier<bool> _combined() {
    final result = ValueNotifier(visible.value && allowedHere.value);
    void update() => result.value = visible.value && allowedHere.value;
    visible.addListener(update);
    allowedHere.addListener(update);
    return result;
  }

  /// Called whenever the router moves.
  void onRoute(String? name) =>
      allowedHere.value = name == null || !closedTo.contains(name);

  Future<void> setVisible({required bool value}) async {
    visible.value = value;
    await _preferences.setBool(_key, value);
  }
}
