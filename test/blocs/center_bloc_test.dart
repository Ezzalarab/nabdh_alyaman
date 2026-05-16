import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/data/models/center_profile_dto.dart';
import 'package:nabdh_alyaman/domain/entities/blood_center.dart';
import 'package:nabdh_alyaman/domain/models/center_profile_form.dart';
import 'package:nabdh_alyaman/domain/repositories/center_repository.dart';
import 'package:nabdh_alyaman/domain/usecases/center/center_use_case.dart';
import 'package:nabdh_alyaman/presentation/blocs/center/center_bloc.dart';

class FakeCenterRepository implements CenterRepository {
  BloodCenter center = BloodCenter(
    name: 'مركز',
    email: '',
    password: '',
    phone: '967771111111',
    state: 'صنعاء',
    district: 'الثورة',
    neighborhood: 'حارة',
    image: '',
    lastUpdate: '',
    lat: '',
    lon: '',
    token: '',
    status: '1',
    stateId: 100,
    districtId: 1001,
    aPlus: 5,
    aMinus: 0,
    bPlus: 0,
    bMinus: 0,
    abPlus: 0,
    abMinus: 0,
    oPlus: 0,
    oMinus: 0,
  );

  int adjustCalls = 0;
  int? lastDonorId;

  @override
  Future<Either<Failure, BloodCenter>> getMe() async => Right(center);

  @override
  Future<Either<Failure, BloodCenter>> updateProfile({
    required ProfileCenterData data,
  }) async {
    center = BloodCenter(
      name: data.name ?? center.name,
      email: center.email,
      password: '',
      phone: data.phone ?? center.phone,
      state: center.state,
      district: center.district,
      neighborhood: data.neighborhood ?? center.neighborhood,
      image: center.image,
      lastUpdate: center.lastUpdate,
      lat: center.lat,
      lon: center.lon,
      token: '',
      status: '1',
      stateId: data.stateId ?? center.stateId,
      districtId: data.districtId ?? center.districtId,
      locationId: data.locationId ?? center.locationId,
      aPlus: center.aPlus,
      aMinus: center.aMinus,
      bPlus: center.bPlus,
      bMinus: center.bMinus,
      abPlus: center.abPlus,
      abMinus: center.abMinus,
      oPlus: center.oPlus,
      oMinus: center.oMinus,
    );
    return Right(center);
  }

  @override
  Future<Either<Failure, Unit>> adjustStock({
    required String bloodType,
    required int change,
    String? reason,
  }) async {
    adjustCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, CenterDonationResult>> recordDonation({
    required int donorId,
    String? notes,
  }) async {
    lastDonorId = donorId;
    return Right(CenterDonationResult(eligibleUntil: '2026-08-01'));
  }

  @override
  Future<Either<Failure, CenterStockHistoryPage>> getStockHistory({
    String? cursor,
    int? limit,
  }) async {
    return Right(
      CenterStockHistoryPage(
        items: [
          CenterStockHistoryEntry(
            id: '1',
            bloodType: 'A+',
            change: 2,
            reason: 'تبرع',
            createdAt: '2026-01-01',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> applyStockDeltas({
    required ProfileCenterData current,
    required Map<String, int> baseline,
    String? reason,
  }) async {
    for (final _ in current.stockDeltas(baseline)) {
      adjustCalls++;
    }
    return const Right(unit);
  }
}

void main() {
  late FakeCenterRepository repo;
  late CenterUseCase useCase;

  setUp(() {
    repo = FakeCenterRepository();
    useCase = CenterUseCase(centerRepository: repo);
  });

  blocTest<CenterBloc, CenterState>(
    'CenterProfileLoadRequested emits CenterProfileLoaded',
    build: () => CenterBloc(centerUseCase: useCase),
    act: (bloc) => bloc.add(CenterProfileLoadRequested()),
    verify: (bloc) {
      expect(bloc.state, isA<CenterProfileLoaded>());
      final loaded = bloc.state as CenterProfileLoaded;
      expect(loaded.center.name, 'مركز');
      expect(loaded.stockBaseline['A+'], 5);
    },
  );

  blocTest<CenterBloc, CenterState>(
    'CenterStockSaveSubmitted applies deltas',
    build: () => CenterBloc(centerUseCase: useCase),
    seed: () => CenterProfileLoaded(
      center: repo.center,
      stockBaseline: {'A+': 5},
    ),
    act: (bloc) {
      final form = ProfileCenterData.fromBloodCenter(repo.center);
      form.aPlus = 7;
      bloc.add(
        CenterStockSaveSubmitted(
          current: form,
          baseline: {'A+': 5},
          reason: 'test',
        ),
      );
    },
    verify: (_) => expect(repo.adjustCalls, greaterThan(0)),
  );

  blocTest<CenterBloc, CenterState>(
    'CenterDonationRecordSubmitted emits success message',
    build: () => CenterBloc(centerUseCase: useCase),
    act: (bloc) => bloc.add(
      CenterDonationRecordSubmitted(donorId: 42, notes: 'ok'),
    ),
    verify: (bloc) {
      expect(repo.lastDonorId, 42);
      expect(bloc.state, isA<CenterSuccess>());
    },
  );

  blocTest<CenterBloc, CenterState>(
    'CenterStockHistoryLoadRequested loads items',
    build: () => CenterBloc(centerUseCase: useCase),
    act: (bloc) => bloc.add(CenterStockHistoryLoadRequested()),
    verify: (bloc) {
      expect(bloc.state, isA<CenterStockHistoryLoaded>());
      expect((bloc.state as CenterStockHistoryLoaded).items, isNotEmpty);
    },
  );
}
