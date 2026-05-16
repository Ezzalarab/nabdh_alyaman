import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/app_notification.dart';
import '../../../domain/usecases/notifications_use_case.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required NotificationsUseCase notificationsUseCase})
      : _useCase = notificationsUseCase,
        super(NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationReceived>(_onReceived);
  }

  final NotificationsUseCase _useCase;

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!event.append) {
      emit(NotificationsLoading());
    } else if (state is NotificationsLoaded) {
      emit((state as NotificationsLoaded).copyWith(loadingMore: true));
    }

    final result = await _useCase.load(cursor: event.cursor, limit: 20);
    result.fold(
      (failure) => emit(
        NotificationsFailure(getFailureMessage(failure)),
      ),
      (page) {
        if (event.append && state is NotificationsLoaded) {
          final current = state as NotificationsLoaded;
          emit(
            NotificationsLoaded(
              items: [...current.items, ...page.items],
              nextCursor: page.nextCursor,
            ),
          );
        } else {
          emit(
            NotificationsLoaded(
              items: page.items,
              nextCursor: page.nextCursor,
            ),
          );
        }
      },
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _useCase.markRead(event.id);
    result.fold(
      (failure) => emit(NotificationsFailure(getFailureMessage(failure))),
      (_) {
        if (state is! NotificationsLoaded) return;
        final current = state as NotificationsLoaded;
        final items = current.items
            .map(
              (n) => n.id == event.id
                  ? AppNotification(
                      id: n.id,
                      title: n.title,
                      body: n.body,
                      createdAt: n.createdAt,
                      isRead: true,
                      type: n.type,
                      requestId: n.requestId,
                    )
                  : n,
            )
            .toList(growable: false);
        emit(current.copyWith(items: items));
      },
    );
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _useCase.markAllRead();
    result.fold(
      (failure) => emit(NotificationsFailure(getFailureMessage(failure))),
      (_) => add(NotificationsLoadRequested()),
    );
  }

  void _onReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    add(NotificationsLoadRequested());
  }
}
