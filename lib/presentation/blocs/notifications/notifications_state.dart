part of 'notifications_bloc.dart';

sealed class NotificationsState {}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoading extends NotificationsState {}

final class NotificationsLoaded extends NotificationsState {
  NotificationsLoaded({
    required this.items,
    this.nextCursor,
    this.loadingMore = false,
  });

  final List<AppNotification> items;
  final String? nextCursor;
  final bool loadingMore;

  NotificationsLoaded copyWith({
    List<AppNotification>? items,
    String? nextCursor,
    bool? loadingMore,
  }) {
    return NotificationsLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

final class NotificationsFailure extends NotificationsState {
  NotificationsFailure(this.message);

  final String message;
}
