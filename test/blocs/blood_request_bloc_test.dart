import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/domain/entities/blood_request.dart';
import 'package:nabdh_alyaman/domain/repositories/blood_request_repository.dart';
import 'package:nabdh_alyaman/domain/usecases/blood_request_use_case.dart';
import 'package:nabdh_alyaman/presentation/blocs/blood_request/blood_request_bloc.dart';

class FakeBloodRequestRepository implements BloodRequestRepository {
  Either<Failure, BloodRequest>? createResult;
  Either<Failure, BloodRequestPageResult>? listResult;
  Either<Failure, BloodRequest>? detailResult;
  Either<Failure, BloodRequest>? updateResult;

  @override
  Future<Either<Failure, BloodRequest>> create(
    BloodRequestCreateParams params,
  ) async =>
      createResult ?? Left(UnknownFailure());

  @override
  Future<Either<Failure, BloodRequestPageResult>> loadList({
    String? bloodType,
    int? stateId,
    String? cursor,
    int? limit,
  }) async =>
      listResult ?? const Right(BloodRequestPageResult(items: []));

  @override
  Future<Either<Failure, BloodRequest>> loadDetail(String id) async =>
      detailResult ?? Left(UnknownFailure());

  @override
  Future<Either<Failure, BloodRequest>> updateStatus({
    required String id,
    required String status,
  }) async =>
      updateResult ?? Left(UnknownFailure());
}

void main() {
  late FakeBloodRequestRepository repository;
  late BloodRequestUseCase useCase;

  const sample = BloodRequest(
    id: '42',
    bloodType: 'O+',
    locationId: 1,
    hospitalName: 'مستشفى',
    lat: 15.3,
    lon: 44.2,
    unitsNeeded: 2,
    urgency: 'HIGH',
    status: 'OPEN',
    requesterId: '7',
  );

  const createParams = BloodRequestCreateParams(
    bloodType: 'O+',
    locationId: 1,
    hospitalName: 'مستشفى',
    lat: 15.3,
    lon: 44.2,
    unitsNeeded: 2,
    urgency: 'HIGH',
  );

  setUp(() {
    repository = FakeBloodRequestRepository();
    useCase = BloodRequestUseCase(repository: repository);
  });

  BloodRequestBloc buildBloc() => BloodRequestBloc(useCase: useCase);

  blocTest<BloodRequestBloc, BloodRequestState>(
    'BloodRequestCreateSubmitted emits success',
    build: buildBloc,
    setUp: () {
      repository.createResult = const Right(sample);
    },
    act: (bloc) => bloc.add(BloodRequestCreateSubmitted(createParams)),
    expect: () => [
      isA<BloodRequestLoading>(),
      isA<BloodRequestSuccess>(),
    ],
  );

  blocTest<BloodRequestBloc, BloodRequestState>(
    'BloodRequestCreateSubmitted maps 429 to clear message',
    build: buildBloc,
    setUp: () {
      repository.createResult = Left(
        ThrottledFailure(message: 'طلب مفتوح موجود'),
      );
    },
    act: (bloc) => bloc.add(BloodRequestCreateSubmitted(createParams)),
    expect: () => [
      isA<BloodRequestLoading>(),
      predicate<BloodRequestFailure>(
        (s) => s.message.contains('طلب مفتوح موجود'),
      ),
    ],
  );

  blocTest<BloodRequestBloc, BloodRequestState>(
    'BloodRequestDetailLoadRequested emits detail',
    build: buildBloc,
    setUp: () {
      repository.detailResult = const Right(sample);
    },
    act: (bloc) => bloc.add(BloodRequestDetailLoadRequested(id: '42')),
    expect: () => [
      isA<BloodRequestLoading>(),
      isA<BloodRequestDetailLoaded>(),
    ],
  );

  blocTest<BloodRequestBloc, BloodRequestState>(
    'BloodRequestStatusUpdateSubmitted emits updated detail',
    build: buildBloc,
    setUp: () {
      repository.updateResult = const Right(
        BloodRequest(
          id: '42',
          bloodType: 'O+',
          locationId: 1,
          hospitalName: 'مستشفى',
          lat: 15.3,
          lon: 44.2,
          unitsNeeded: 2,
          urgency: 'HIGH',
          status: 'FULFILLED',
        ),
      );
    },
    act: (bloc) => bloc.add(
      BloodRequestStatusUpdateSubmitted(id: '42', status: 'FULFILLED'),
    ),
    expect: () => [
      isA<BloodRequestLoading>(),
      isA<BloodRequestDetailLoaded>(),
    ],
  );
}
