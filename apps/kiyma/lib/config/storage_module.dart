import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Platform singletons the container hands out.
@module
abstract class StorageModule {
  /// Awaited inside `configureDependencies`, so everything downstream of it
  /// stays synchronous — including the startup job that has to know whether
  /// this device has been here before.
  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();
}
