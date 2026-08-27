import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/application/reminder_scheduler.dart';
import 'package:motto/features/chain/domain/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The chain's reminders, scheduled on the device.
///
/// Local rather than push: every reminder here is a function of a date the
/// phone already knows, so a server that would have to stay up — and stay free
/// — buys nothing.
@LazySingleton(as: ReminderScheduler)
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler();

  static const channelId = 'chain';
  static const channelName = 'Zincir';

  /// Not injected: this is a factory over one instance the package already
  /// owns. The seam tests use is [ReminderScheduler].
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
    // iOS has no query that does not also prompt, and spending the one-shot
    // prompt to answer a question nobody asked is worse than assuming yes.
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
        // alarm and calendar apps. A reminder that arrives a few minutes late
        // is a reminder; a rejected listing is not.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _prepare();
    await _plugin.cancelAll();
  }

  /// Both failures here are silent, which is why this runs before anything:
  /// `zonedSchedule` does nothing on an uninitialised plugin, and without the
  /// timezone database every scheduled time is read as UTC — three hours off,
  /// every day, with no error anywhere.
  Future<void> _prepare() async {
    if (_prepared) return;

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // The permission is asked for when the chain starts, not on the launch
        // that happens to initialise this.
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
