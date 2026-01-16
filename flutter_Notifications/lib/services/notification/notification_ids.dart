class NotificationIds {
  static int generate() =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
