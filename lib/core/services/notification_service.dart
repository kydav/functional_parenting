import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the app's daily reminder notifications (tip + challenge). Uses
/// inexact daily scheduling so it needs no exact-alarm permission on Android.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Fixed notification ids so re-scheduling replaces the prior one.
  static const int tipId = 1001;
  static const int challengeId = 1002;

  static const _channel = AndroidNotificationChannel(
    'daily_reminders',
    'Daily reminders',
    description: 'Your daily parenting tip and challenge',
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await _localTimeZone()));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      // We request permission explicitly later, not at init.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  /// Prompts for notification permission. Returns true if granted (or already).
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  Future<void> scheduleDailyTip({int hour = 9, int minute = 0}) =>
      _scheduleDaily(
        id: tipId,
        hour: hour,
        minute: minute,
        title: "Today's parenting tip",
        body: 'A fresh tip is waiting — take a mindful minute. 🌱',
      );

  Future<void> scheduleDailyChallenge({int hour = 12, int minute = 0}) =>
      _scheduleDaily(
        id: challengeId,
        hour: hour,
        minute: minute,
        title: "Today's challenge",
        body: "Ready for today's small win? Tap to see it.",
      );

  Future<void> cancelTip() => _plugin.cancel(id: tipId);
  Future<void> cancelChallenge() => _plugin.cancel(id: challengeId);

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily reminders',
          channelDescription: 'Your daily parenting tip and challenge',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<String> _localTimeZone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      return 'UTC';
    }
  }
}
