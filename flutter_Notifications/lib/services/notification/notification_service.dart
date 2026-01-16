import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_channels.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings);
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = NotificationDetails(
      android: NotificationChannels.taskChannel,
    );

    await _plugin.show(id, title, body, details);
  }
}
