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

  // ── 오늘의 단어 알림 (2000번대 ID 사용) ────────────────────
  static const int _wordIdBase = 2000;
  static const int wordDaysAhead = 14; // 앞으로 14일치를 미리 예약

  Future<void> cancelWordAlarms() async {
    await init();
    for (int i = 0; i < wordDaysAhead; i++) {
      await _plugin.cancel(_wordIdBase + i);
    }
  }

  /// [batches] 는 하루치씩의 알림 본문 목록. 오늘부터 하루 간격으로 예약된다.
  Future<void> scheduleWordAlarms({
    required int hour,
    required int minute,
    required List<String> batches,
  }) async {
    await init();
    await cancelWordAlarms();

    final now = DateTime.now();
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    for (int i = 0; i < batches.length && i < wordDaysAhead; i++) {
      final when = tz.TZDateTime.from(first.add(Duration(days: i)), tz.local);
      await _plugin.zonedSchedule(
        _wordIdBase + i,
        '📚 오늘의 영단어',
        batches[i],
        when,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_words',
            '오늘의 단어',
            channelDescription: '매일 정해진 시간에 영단어를 보내줍니다',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(batches[i]),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
