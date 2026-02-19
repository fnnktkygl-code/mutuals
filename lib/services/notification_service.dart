import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return; // Notifications not supported on web

    tz.initializeTimeZones();
    
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return; // Not supported on web

    // Use defaultTargetPlatform instead of dart:io Platform for web compatibility
    final platform = TargetPlatform.values;
    try {
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    } catch (_) {
      // Platform implementation not available
    }
  }

  Future<void> scheduleBirthdayNotification({
    required String id,
    required String name,
    required DateTime birthday,
  }) async {
    if (kIsWeb) return; // Not supported on web

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      birthday.month,
      birthday.day,
      9, // 9:00 AM
      0,
    );

    // If birthday has passed this year, schedule for next year
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 365));
    }

    await notificationsPlugin.zonedSchedule(
      id: id.hashCode,
      title: 'C\'est l\'anniversaire de $name ! 🎂',
      body: 'N\'oubliez pas de lui souhaiter un joyeux anniversaire.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'birthdays_channel',
          'Anniversaires',
          channelDescription: 'Rappels d\'anniversaires',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime, // Repeats yearly
    );
  }

  Future<void> cancelNotification(String id) async {
    if (kIsWeb) return;
    await notificationsPlugin.cancel(id: id.hashCode);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await notificationsPlugin.cancelAll();
  }
}
