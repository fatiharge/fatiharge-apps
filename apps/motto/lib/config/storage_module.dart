import 'package:android_id/android_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Platform singletons the container hands out.
@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  AndroidId get androidId => const AndroidId();
}
