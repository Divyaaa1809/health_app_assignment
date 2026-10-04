import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
  }

  Future<void> showHealthReminder() async {
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
      id: 1,
      title: 'Health Dashboard',
      body: 'Time to check your daily health metrics.',
      notificationDetails: details,
    );
  }
}
