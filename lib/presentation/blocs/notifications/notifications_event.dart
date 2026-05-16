part of 'notifications_bloc.dart';

sealed class NotificationsEvent {}

final class NotificationsLoadRequested extends NotificationsEvent {
  NotificationsLoadRequested({this.append = false, this.cursor});

  final bool append;
  final String? cursor;
}

final class NotificationMarkReadRequested extends NotificationsEvent {
  NotificationMarkReadRequested(this.id);

  final int id;
}

final class NotificationsMarkAllReadRequested extends NotificationsEvent {}

final class NotificationReceived extends NotificationsEvent {
  NotificationReceived(this.message);

  final RemoteMessage message;
}
