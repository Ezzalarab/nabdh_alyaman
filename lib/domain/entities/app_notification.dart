class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.type,
    this.requestId,
  });

  final int id;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;
  final String? type;
  final String? requestId;
}

class NotificationPageResult {
  const NotificationPageResult({
    required this.items,
    this.nextCursor,
  });

  final List<AppNotification> items;
  final String? nextCursor;
}
