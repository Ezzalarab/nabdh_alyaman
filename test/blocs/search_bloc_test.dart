import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/domain/entities/blood_center.dart';
import 'package:nabdh_alyaman/domain/entities/donor.dart';
import 'package:nabdh_alyaman/domain/repositories/search_repo.dart';
import 'package:nabdh_alyaman/domain/usecases/search_centers_uc.dart';
import 'package:nabdh_alyaman/domain/usecases/search_donors_uc.dart';
import 'package:nabdh_alyaman/presentation/blocs/search/search_bloc.dart';

class FakeSearchRepo implements SearchRepo {
  Either<Failure, List<Donor>>? donorsResult;
  Either<Failure, List<BloodCenter>>? centersResult;

  @override
  Future<Either<Failure, List<Donor>>> searchDonors({
    required String bloodType,
    required int stateId,
    required int districtId,
  }) async =>
      donorsResult ?? const Right([]);

  @override
  Future<Either<Failure, List<BloodCenter>>> searchCenters({
    required int stateId,
    required int districtId,
  }) async =>
      centersResult ?? const Right([]);
}

void main() {
  late FakeSearchRepo repo;
  late SearchBloc bloc;

  final donor = Donor(
    id: '1',
    email: '',
    name: 'D',
    phone: '967771234567',
    bloodType: 'O+',
    state: '1',
    district: '1',
    neighborhood: '',
    lat: '15',
    lon: '44',
    brithDate: '',
    image: '',
    isShown: '1',
    isShownPhone: '1',
    isGpsOn: '1',
    token: '',
  );

  final center = BloodCenter(
    name: 'Center',
    email: '',
    password: '',
    phone: '967771111111',
    state: '1',
    district: '1',
    neighborhood: '',
    image: '',
    lastUpdate: '',
    lat: '15',
    lon: '44',
    token: '',
    status: 'active',
    aPlus: 0,
    aMinus: 0,
    bPlus: 0,
    bMinus: 0,
    abPlus: 0,
    abMinus: 0,
    oPlus: 1,
    oMinus: 0,
  );

  setUp(() {
    repo = FakeSearchRepo();
    bloc = SearchBloc(
      searchDonorsUC: SearchDonorsUC(searchRepository: repo),
      searchCentersUC: SearchCentersUC(searchRepository: repo),
    );
  });

  tearDown(() => bloc.close());

  blocTest<SearchBloc, SearchState>(
    'SearchRequested without filters emits failure',
    build: () => bloc,
    act: (b) => b.add(const SearchRequested()),
    expect: () => [
      isA<SearchFailure>(),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'SearchRequested emits success with donors and centers',
    build: () => bloc,
    setUp: () {
      repo.donorsResult = Right([donor]);
      repo.centersResult = Right([center]);
    },
    act: (b) => b.add(
      const SearchRequested(
        bloodType: 'O+',
        stateId: 1,
        districtId: 1,
      ),
    ),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchSuccess>(),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'SearchTabChanged updates tab on success state',
    build: () => bloc,
    seed: () => SearchSuccess(
      donors: [donor],
      centers: [center],
      stateDonors: [donor],
      selectedTabIndex: 0,
      bloodType: 'O+',
      stateId: 1,
      districtId: 1,
    ),
    act: (b) => b.add(const SearchTabChanged(1)),
    expect: () => [
      predicate<SearchSuccess>((s) => s.selectedTabIndex == 1),
    ],
  );
}
