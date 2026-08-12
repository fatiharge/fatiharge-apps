import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// The third-party singletons the adapters wrap.
@module
abstract class PlatformModule {
  /// Handed over uninitialised. Initialising here would make
  /// `configureDependencies()` reach for a platform channel, which is both
  /// more than DI should need and work done for someone who may never turn a
  /// reminder on — the adapter does it on first use instead.
  @singleton
  FlutterLocalNotificationsPlugin get notifications =>
      FlutterLocalNotificationsPlugin();
}
