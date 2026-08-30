import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the definitions live between launches.
///
/// The same shape as the content package, for the same reason: a file rather
/// than preferences, and a version beside it so most launches ask and are told
/// nothing changed.
@lazySingleton
class EffectStore {
  EffectStore(this._preferences);

  static const _versionKey = 'effects_version';
  static const _fileName = 'effects.json';

  final SharedPreferences _preferences;

  String? get version => _preferences.getString(_versionKey);

  Future<Map<String, dynamic>?> readCached() async {
    final file = await _file();
    if (!file.existsSync()) return null;

    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } on Object {
      // Definitions that will not parse would not parse on the next launch
      // either, and the app is designed to survive having none.
      await file.delete();
      await _preferences.remove(_versionKey);
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> definitions, String version) async {
    await (await _file()).writeAsString(jsonEncode(definitions), flush: true);
    await _preferences.setString(_versionKey, version);
  }

  Future<File> _file() async =>
      File('${(await getApplicationSupportDirectory()).path}/$_fileName');
}
