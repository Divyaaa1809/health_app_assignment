import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const settings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(settings: settings);
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> showHealthReminder() async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'health_reminders',
          'Health Reminders',
          channelDescription: 'Daily health dashboard reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

      await _plugin.show(
        id: generateRandomNumber(),
        title: 'Health Reminder',
        body: 'Time to check your daily health metrics.',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  int generateRandomNumber() {
    return Random().nextInt(100) + 1;
  }
}
