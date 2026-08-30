import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which language the app reads in.
///
/// One answer for both halves of the problem. The words that ship inside the
/// app come from `easy_localization`; the words that come down from the server
/// are chosen by the `Accept-Language` header on every request. Two sources
/// would drift the first time somebody changed one of them, and a screen whose
/// title is Turkish over an English paragraph is worse than either language on
/// its own.
///
/// Stored rather than read from the phone each time: somebody who chose English
/// on a Turkish phone meant it, and a choice that is forgotten on restart is
/// not a choice.
@lazySingleton
class AppLanguage {
  AppLanguage(this._preferences);

  static const _key = 'app_language';

  /// The one everything was written in, and the answer to anything unknown.
  static const fallback = 'tr';

  static const supported = ['tr', 'en'];

  final SharedPreferences _preferences;

  /// What goes in the header and what `easy_localization` is set to.
  String get tag => _preferences.getString(_key) ?? _fromDevice();

  Locale get locale => Locale(tag);

  /// True when the language is the phone's rather than a choice. The settings
  /// screen says so, because "Türkçe" next to a phone set to English reads as
  /// a bug until you know nobody picked it.
  bool get chosen => _preferences.getString(_key) != null;

  Future<void> choose(String tag) =>
      _preferences.setString(_key, supported.contains(tag) ? tag : fallback);

  /// The stored choice, before the container exists.
  ///
  /// `main` needs the language one line after the bindings are up and long
  /// before `configureDependencies`, and a frame drawn in the wrong language
  /// is a frame everybody sees.
  static Future<Locale> stored() async {
    final preferences = await SharedPreferences.getInstance();
    return Locale(preferences.getString(_key) ?? _fromDevice());
  }

  /// The phone's language when the app has one for it. A phone set to a
  /// language nobody has written yet reads Turkish, which is the same answer
  /// the server gives.
  static String _fromDevice() {
    final language = PlatformDispatcher.instance.locale.languageCode;
    return supported.contains(language) ? language : fallback;
  }
}
