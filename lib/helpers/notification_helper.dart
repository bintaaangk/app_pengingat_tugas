import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init() async {
    tz.initializeTimeZones();
    // Pastikan icon @mipmap/ic_launcher ada di folder android/app/src/main/res
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);

    // =========================================================
    // INI BAGIAN YANG TERLEWAT: Wajib untuk Android 13 ke atas
    // Memunculkan pop-up minta izin notifikasi & alarm presisi
    // =========================================================
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // Fungsi untuk menjadwalkan notifikasi berulang setiap 2 jam (Sistem Rewel)
  static Future scheduleNaggingNotifications({
    required int id,
    required String title,
    required String body,
    required DateTime startNagging,
    required DateTime deadline,
  }) async {
    // 1. Notifikasi pertama tepat di waktu pengingat yang dipilih
    await _notifications.zonedSchedule(
      id,
      "PENGINGAT: $title",
      "Ayo mulai kerjakan! $body",
      tz.TZDateTime.from(startNagging, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nagging_channel', 
          'Nagging Notifications',
          importance: Importance.max, 
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 2. Loop untuk menjadwalkan notifikasi setiap 2 jam SETELAH startNagging SAMPAI deadline
    DateTime nextTime = startNagging.add(const Duration(hours: 2));
    int subId = id + 1; // ID berbeda untuk setiap notifikasi berulang

    while (nextTime.isBefore(deadline)) {
      await _notifications.zonedSchedule(
        subId,
        "MASIH BELUM?!: $title",
        "Sudah 2 jam berlalu, tugas ini harus segera selesai!",
        tz.TZDateTime.from(nextTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nagging_channel_repeat', 
            'Nagging Repeat',
            importance: Importance.high, 
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      nextTime = nextTime.add(const Duration(hours: 2));
      subId++;
    }
  }

  // Fungsi untuk membatalkan notifikasi (dipanggil kalau tugas sudah dicentang selesai)
  static Future cancelNotification(int id) async {
    await _notifications.cancel(id);
    // Batalkan juga sub-id (kita asumsikan maksimal 20 kali rewel/loop)
    for (int i = 1; i <= 20; i++) {
      await _notifications.cancel(id + i);
    }
  }
}