import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/data/data_sources/local_data.dart';
import 'package:nabdh_alyaman/domain/entities/app_update_policy.dart';
import 'package:nabdh_alyaman/domain/entities/global_app_data.dart';
import 'package:nabdh_alyaman/domain/repositories/app_config_repository.dart';
import 'package:nabdh_alyaman/domain/usecases/load_app_config_uc.dart';
import 'package:nabdh_alyaman/presentation/blocs/app_config/app_config_bloc.dart';

class FakeAppConfigRepository implements AppConfigRepository {
  Either<Failure, AppConfigBundle>? next;

  @override
  Future<Either<Failure, AppConfigBundle>> load({
    required String currentVersion,
  }) async {
    return next ??
        Right(
          AppConfigBundle(
            data: LocalData.initialAppData,
            updatePolicy: AppUpdatePolicy.empty,
            raw: const {},
          ),
        );
  }
}

void main() {
  late FakeAppConfigRepository repository;
  late LoadAppConfigUseCase useCase;

  setUp(() {
    repository = FakeAppConfigRepository();
    useCase = LoadAppConfigUseCase(repository: repository);
  });

  AppConfigBloc buildBloc() => AppConfigBloc(
        loadAppConfig: useCase,
        currentVersionProvider: () async => '1.0.0',
      );

  final loadedData = GlobalAppData(
    appName: 'اختبار',
    aboutApp: 'عن',
    homeHeader: 'ترحيب',
    infoTitle: 'فوائد',
    eventsTitle: 'فعاليات',
    reportLink: 'link',
    infoList: const ['واحد'],
    homeSlides: const ['assets/images/blood_heart.png'],
    eventsCardsData: const [],
  );

  blocTest<AppConfigBloc, AppConfigState>(
    'AppConfigLoadRequested emits loaded on success',
    build: buildBloc,
    setUp: () {
      repository.next = Right(
        AppConfigBundle(
          data: loadedData,
          updatePolicy: AppUpdatePolicy.empty,
          raw: const {},
        ),
      );
    },
    act: (bloc) => bloc.add(AppConfigLoadRequested()),
    verify: (bloc) {
      expect(bloc.state, isA<AppConfigLoaded>());
      final loaded = bloc.state as AppConfigLoaded;
      expect(loaded.data.appName, 'اختبار');
    },
  );

  blocTest<AppConfigBloc, AppConfigState>(
    'AppConfigLoadRequested emits failure with fallback data',
    build: buildBloc,
    setUp: () {
      repository.next = Left(OffLineFailure());
    },
    act: (bloc) => bloc.add(AppConfigLoadRequested()),
    verify: (bloc) {
      expect(bloc.state, isA<AppConfigFailure>());
    },
  );

  blocTest<AppConfigBloc, AppConfigState>(
    'AppConfigLoadRequested uses fallback when version provider throws',
    build: () => AppConfigBloc(
      loadAppConfig: useCase,
      currentVersionProvider: () async => throw StateError('native'),
    ),
    setUp: () {
      repository.next = Right(
        AppConfigBundle(
          data: loadedData,
          updatePolicy: AppUpdatePolicy.empty,
          raw: const {},
        ),
      );
    },
    act: (bloc) => bloc.add(AppConfigLoadRequested()),
    verify: (bloc) {
      expect(bloc.state, isA<AppConfigLoaded>());
      final loaded = bloc.state as AppConfigLoaded;
      expect(loaded.usedFallback, isTrue);
    },
  );

  blocTest<AppConfigBloc, AppConfigState>(
    'AppConfigLoadRequested emits AppUpdateRequired when policy demands',
    build: buildBloc,
    setUp: () {
      repository.next = Right(
        AppConfigBundle(
          data: loadedData,
          updatePolicy: const AppUpdatePolicy(
            shouldPrompt: true,
            targetVersion: '9.0.0',
            message: 'حدّث',
            isBlocking: true,
            storeUrl: 'https://play.google.com',
          ),
          raw: const {},
        ),
      );
    },
    act: (bloc) => bloc.add(AppConfigLoadRequested()),
    verify: (bloc) {
      expect(bloc.state, isA<AppUpdateRequired>());
    },
  );
}
