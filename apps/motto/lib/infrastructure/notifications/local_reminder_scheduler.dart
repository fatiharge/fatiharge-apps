import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local rather than push: every reminder is a function of a date the phone
/// already knows.
@LazySingleton(as: ReminderScheduler)
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler();

  static const channelId = 'chain';
  static const channelName = 'Zincir';

  /// Not injected: the seam tests use is [ReminderScheduler].
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
    // iOS has no query that does not also prompt, and the prompt is one-shot.
    return true;
  }

  @override
  Future<void> schedule(List<Reminder> reminders) async {
    await _prepare();
    await cancelAll();

    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        tz.TZDateTime.from(reminder.at, tz.local),
        _details,
        // Exact alarms need SCHEDULE_EXACT_ALARM, which Play grants only to
        // alarm and calendar apps.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _prepare();
    await _plugin.cancelAll();
  }

  /// Both failures are silent: `zonedSchedule` does nothing on an
  /// uninitialised plugin, and without the timezone database every scheduled
  /// time is read as UTC.
  Future<void> _prepare() async {
    if (_prepared) return;

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Asked for when the chain starts, not on the launch that
        // happens to initialise this.
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

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(channelId, channelName),
    iOS: DarwinNotificationDetails(),
  );
}
