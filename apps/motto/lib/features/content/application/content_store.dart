import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the content package lives between launches.
///
/// A file rather than preferences: this is the biggest thing the app holds, and
/// preferences is a place for small values that are read on every launch.
@lazySingleton
class ContentStore {
  ContentStore(this._preferences);

  static const _versionKey = 'content_version';
  static const _fileName = 'content-bundle.json';

  /// The package the app was built with, so a first launch with no network
  /// still has fourteen days of content. An empty first day is the last day
  /// someone opens this.
  static const bundledAsset = 'assets/content/bundle.json';

  final SharedPreferences _preferences;

  String? get version => _preferences.getString(_versionKey);

  Future<Map<String, dynamic>?> readCached() async {
    final file = await _file();
    if (!file.existsSync()) return null;

    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } on Object {
      // A package that cannot be parsed would fail to parse on every launch.
      // Dropping it costs one download; keeping it costs the app.
      await file.delete();
      await _preferences.remove(_versionKey);
      return null;
    }
  }

  Future<Map<String, dynamic>> readBundled() async =>
      jsonDecode(await rootBundle.loadString(bundledAsset))
          as Map<String, dynamic>;

  Future<void> save(Map<String, dynamic> bundle, String version) async {
    await (await _file()).writeAsString(jsonEncode(bundle), flush: true);
    await _preferences.setString(_versionKey, version);
  }

  Future<File> _file() async =>
      File('${(await getApplicationSupportDirectory()).path}/$_fileName');
}
