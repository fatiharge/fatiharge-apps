import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:wallet/features/finance/domain/rules/summary_schedule.dart';
import 'package:wallet/features/settings/domain/summary_notifier.dart';

/// [SummaryNotifier] over `flutter_local_notifications`.
@LazySingleton(as: SummaryNotifier)
class SummaryNotifierAdapter implements SummaryNotifier {
  SummaryNotifierAdapter(this._plugin);

  /// One channel, one id space: rescheduling cancels the lot and writes the
  /// window again, so ids only have to be unique within a single window.
  static const String channelId = 'monthly_summary';
  static const int firstNotificationId = 1000;

  final FlutterLocalNotificationsPlugin _plugin;

  bool _timeZonesLoaded = false;

  @override
  Future<bool> requestPermission() async {
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
    // iOS has no query that does not also prompt, so the stored answer is the
    // best the app has until it asks again.
    return true;
  }

  @override
  Future<void> schedule({
    required int day,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await cancel();
    await _loadTimeZones();

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
        // Inexact on purpose: exact alarms need SCHEDULE_EXACT_ALARM, which
        // Play restricts to alarm-and-calendar apps. A monthly summary does
        // not care about the minute.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancel() => _plugin.cancelAll();

  @override
  Future<void> openSystemSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);

  /// The database is several hundred kilobytes, so it is loaded the first time
  /// something is actually scheduled rather than at startup.
  Future<void> _loadTimeZones() async {
    if (_timeZonesLoaded) return;
    tz_data.initializeTimeZones();
    _timeZonesLoaded = true;
  }

  /// The channel name is what Android shows in its own notification settings,
  /// so it is translated text like everything else on screen.
  static NotificationDetails _detailsFor(String channelName) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
        ),
        iOS: const DarwinNotificationDetails(),
      );
}
