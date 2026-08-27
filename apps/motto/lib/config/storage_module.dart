import 'package:android_id/android_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Platform singletons the container hands out.
@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  AndroidId get androidId => const AndroidId();

  /// Resolved during initialisation rather than on first use: it is the only
  /// one of these that has to be awaited, and everything downstream of it is
  /// synchronous.
  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();
}
