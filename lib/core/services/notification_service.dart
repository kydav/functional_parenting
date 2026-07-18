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

  static const _workshopChannel = AndroidNotificationChannel(
    'workshop_reminders',
    'Workshop reminders',
    description: "Reminders for workshops you've reserved",
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    // Some devices report a timezone id that isn't in the tz database, which
    // makes getLocation throw. Fall back to UTC so startup can't be blocked.
    try {
      tz.setLocalLocation(tz.getLocation(await _localTimeZone()));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('ic_notification');
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

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);
    await android?.createNotificationChannel(_workshopChannel);

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

  // ── Workshop reminders (10 minutes before start) ─────────────────────────

  /// Stable, positive notification id derived from the workshop id. Offset well
  /// clear of the fixed daily ids.
  int _workshopNotifId(String workshopId) =>
      100000 + (workshopId.hashCode & 0x0FFFFFFF);

  /// Schedules (or replaces) a one-time reminder 10 minutes before [startsAt].
  /// No-op if that moment is already in the past.
  Future<void> scheduleWorkshopReminder({
    required String workshopId,
    required String title,
    required DateTime startsAt,
  }) async {
    await init();
    final when = tz.TZDateTime.from(
      startsAt.subtract(const Duration(minutes: 10)),
      tz.local,
    );
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    if (!await requestPermission()) return;
    await _plugin.zonedSchedule(
      id: _workshopNotifId(workshopId),
      title: 'Starting soon: $title',
      body: 'Your workshop begins in 10 minutes. Tap to join.',
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'workshop_reminders',
          'Workshop reminders',
          icon: 'ic_notification',
          channelDescription: "Reminders for workshops you've reserved",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelWorkshopReminder(String workshopId) =>
      _plugin.cancel(id: _workshopNotifId(workshopId));

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
          icon: 'ic_notification',
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
