import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/domain/entities/app_notification.dart';
import 'package:nabdh_alyaman/domain/repositories/notifications_repository.dart';
import 'package:nabdh_alyaman/domain/usecases/notifications_use_case.dart';
import 'package:nabdh_alyaman/presentation/blocs/notifications/notifications_bloc.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  NotificationPageResult page = const NotificationPageResult(items: []);

  @override
  Future<Either<Failure, NotificationPageResult>> load({
    String? cursor,
    int? limit,
  }) async =>
      Right(page);

  @override
  Future<Either<Failure, Unit>> markRead(int id) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> markAllRead() async => const Right(unit);
}

void main() {
  late FakeNotificationsRepository repository;
  late NotificationsUseCase useCase;

  setUp(() {
    repository = FakeNotificationsRepository();
    useCase = NotificationsUseCase(repository: repository);
  });

  NotificationsBloc buildBloc() =>
      NotificationsBloc(notificationsUseCase: useCase);

  const sample = AppNotification(
    id: 1,
    title: 'طلب دم',
    body: 'تفاصيل',
    createdAt: '2026-01-01',
    isRead: false,
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'NotificationsLoadRequested emits loaded list',
    build: buildBloc,
    setUp: () {
      repository.page = const NotificationPageResult(
        items: [sample],
        nextCursor: 'c1',
      );
    },
    act: (bloc) => bloc.add(NotificationsLoadRequested()),
    expect: () => [
      isA<NotificationsLoading>(),
      isA<NotificationsLoaded>(),
    ],
    verify: (bloc) {
      final state = bloc.state as NotificationsLoaded;
      expect(state.items.length, 1);
      expect(state.nextCursor, 'c1');
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'NotificationMarkReadRequested marks item read locally',
    build: buildBloc,
    setUp: () {
      repository.page = const NotificationPageResult(items: [sample]);
    },
    act: (bloc) async {
      bloc.add(NotificationsLoadRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(NotificationMarkReadRequested(1));
    },
    skip: 1,
    verify: (bloc) {
      final state = bloc.state as NotificationsLoaded;
      expect(state.items.first.isRead, true);
    },
  );
}
