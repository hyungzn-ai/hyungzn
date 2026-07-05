import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleDaily({int hour = 20, int minute = 0}) async {
    await init();
    await _plugin.cancel(1001);
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    final scheduled = tz.TZDateTime.from(target, tz.local);
    await _plugin.zonedSchedule(
      1001,
      '영작몬이 기다려요 🐾',
      '오늘의 영작 아직이에요! 5문장만 쓰고 스트릭을 지켜요 🔥',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '데일리 알림',
          channelDescription: '매일 학습 리마인더',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() async {
    await init();
    await _plugin.cancel(1001);
  }
}
