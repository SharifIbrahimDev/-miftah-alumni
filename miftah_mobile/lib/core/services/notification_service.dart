import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'miftah_channel',
      'General Notifications',
      channelDescription: 'General chapter updates and payment alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> notifyPaymentSuccess(String month, double amount) async {
    await showNotification(
      title: 'Payment Confirmed',
      body: 'Your contribution for $month (N${amount.toStringAsFixed(0)}) has been recorded.',
      id: 1,
    );
  }

  static Future<void> notifyProjectContribution(String name, double amount) async {
    await showNotification(
      title: 'Contribution Received',
      body: 'Thank you for donating N${amount.toStringAsFixed(0)} to the $name project!',
      id: 2,
    );
  }
}
