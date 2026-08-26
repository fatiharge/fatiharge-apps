import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:wallet/config/env.dart';
import 'package:wallet/features/finance/domain/rules/summary_schedule.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';

@LazySingleton(as: SummaryNotifier)
class SummaryNotifierAdapter implements SummaryNotifier {
  SummaryNotifierAdapter();

  /// Rescheduling cancels the lot, so ids need only be unique within a window.
  static const String channelId = 'monthly_summary';
  static const int firstNotificationId = 1000;

  /// Not injected: the constructor is a factory over one instance the package
  /// already owns. The seam tests use is [SummaryNotifier].
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _prepared = false;

  @override
  Future<bool> requestPermission() async {
    await _prepare();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true) ?? false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<bool> hasPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    // iOS has no query that does not also prompt.
    return true;
  }

  @override
  Future<void> schedule({
    required int day,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await _prepare();
    await cancel();

    // Posted, not scheduled: an inexact alarm is deferred past the minute it
    // was aimed at, and every `flutter run` cancels pending alarms anyway.
    if (Env.debugGrowth) {
      await _plugin.show(
        firstNotificationId,
        title,
        body,
        _detailsFor(channelName),
      );
      return;
    }

    final occurrences = SummarySchedule.occurrencesAfter(
      DateTime.now(),
      day: day,
    );

    for (final (index, at) in occurrences.indexed) {
      await _plugin.zonedSchedule(
        firstNotificationId + index,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        _detailsFor(channelName),
        // Exact alarms need SCHEDULE_EXACT_ALARM, which Play restricts to
        // alarm-and-calendar apps.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancel() => _plugin.cancelAll();

  @override
  Future<void> openSystemSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);

  /// Both failures here are silent: `zonedSchedule` does nothing on an
  /// uninitialised plugin, and without the timezone database every scheduled
  /// time reads as UTC. The request flags default to true and would spend
  /// iOS's one-shot prompt on whoever merely opened settings.
  Future<void> _prepare() async {
    if (_prepared) return;

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    tz_data.initializeTimeZones();
    _prepared = true;
  }

  /// Android shows the channel name in its own settings, so it is translated.
  static NotificationDetails _detailsFor(String channelName) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
        ),
        iOS: const DarwinNotificationDetails(),
      );
}
