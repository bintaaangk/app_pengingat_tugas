import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Inisialisasi Zona Waktu (Wajib buat jadwal alarm)
    tz.initializeTimeZones();

    // 2. Settingan Ikon Aplikasi untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Settingan untuk iOS (Apple)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 4. Mulai Plugin-nya
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notifikasi diklik: ${response.payload}');
      },
    );

    // 5. Khusus Android 13+: Minta izin munculin notif ke user
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  // FUNGSI UNTUK JADWALKAN ALARM HP POP-UP
  static Future<void> scheduleNaggingNotifications({
    required int id,
    required String title,
    required String body,
    required DateTime startNagging,
    required DateTime deadline,
  }) async {
    // Settingan agar Notifikasi muncul sebagai Pop-up di atas (Heads-up) dan Bunyi Alarm
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'rewel_channel_id', // ID Channel
      'Pengingat Tugas Rewel', // Nama Channel
      channelDescription: 'Alarm pop-up untuk tugas yang belum selesai',
      importance: Importance.max, // Bikin muncul Pop-up di atas layar
      priority: Priority.high,
      playSound: true, // Bikin bunyi
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
    );

    // Konversi jam di HP kamu jadi format zona waktu lokal
    final scheduledTime = tz.TZDateTime.from(startNagging, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // WAJIB: Biar tetep bunyi pas HP kekunci
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Alarm diset untuk: $scheduledTime");
    } catch (e) {
      debugPrint("Gagal set alarm: $e");
    }
  }

  // FUNGSI UNTUK MEMBATALKAN ALARM
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint("Alarm ID $id dibatalkan karena tugas selesai.");
  }
}