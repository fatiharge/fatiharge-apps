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
    await _prepare();
    await cancel();

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

  /// Initialises the plugin and loads the timezone database, once, the first
  /// time either is actually needed.
  ///
  /// `zonedSchedule` silently does nothing on a plugin that was never
  /// initialised, and without the timezone database every scheduled time is
  /// read as UTC — both are quiet failures, which is why this is not left to
  /// chance. Every request flag is off: they default to true, and would throw
  /// iOS's one-shot permission prompt at whoever merely opened settings.
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
