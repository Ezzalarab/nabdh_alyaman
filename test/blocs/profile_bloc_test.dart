import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/domain/entities/donor.dart';
import 'package:nabdh_alyaman/domain/repositories/profile_repository.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/domain/usecases/profile_use_case.dart';
import 'package:nabdh_alyaman/presentation/blocs/profile/profile_bloc.dart';
import 'package:nabdh_alyaman/presentation/widgets/setting/profile_body.dart';

class FakeProfileRepository implements ProfileRepository {
  ProfileLocalData? lastBasicPatch;

  Donor donor = Donor(
    id: '1',
    email: '',
    name: 'Test',
    phone: '967771234567',
    bloodType: 'O+',
    state: '100',
    district: '1001',
    neighborhood: '',
    lat: '',
    lon: '',
    brithDate: '',
    image: '',
    isShown: '1',
    isShownPhone: '1',
    isGpsOn: '1',
    token: '',
  );

  @override
  Future<Either<Failure, Donor>> getDataToProfilePage() async => Right(donor);

  @override
  Future<Either<Failure, Unit>> sendDataProfileSectionOne({
    required ProfileLocalData profileLocalData,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> sendBasicDataProfileSectionOne({
    required ProfileLocalData profileLocalData,
  }) async {
    lastBasicPatch = profileLocalData;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Donor>> uploadDonorProfileImage({
    required File file,
  }) async {
    donor = Donor(
      id: donor.id,
      email: donor.email,
      name: donor.name,
      phone: donor.phone,
      bloodType: donor.bloodType,
      state: donor.state,
      district: donor.district,
      neighborhood: donor.neighborhood,
      lat: donor.lat,
      lon: donor.lon,
      brithDate: donor.brithDate,
      image: '42',
      isShown: donor.isShown,
      isShownPhone: donor.isShownPhone,
      isGpsOn: donor.isGpsOn,
      token: donor.token,
    );
    return Right(donor);
  }
}

void main() {
  late FakeProfileRepository repo;
  late ProfileUseCase useCase;

  setUp(() {
    repo = FakeProfileRepository();
    useCase = ProfileUseCase(profileRepository: repo);
  });

  blocTest<ProfileBloc, ProfileState>(
    'ProfileLoadRequested ends with ProfileGetData',
    build: () => ProfileBloc(profileUseCase: useCase),
    act: (bloc) => bloc.add(ProfileLoadRequested()),
    verify: (bloc) => expect(bloc.state, isA<ProfileGetData>()),
  );

  blocTest<ProfileBloc, ProfileState>(
    'ProfileBasicDataUpdateSubmitted passes location IDs',
    build: () => ProfileBloc(profileUseCase: useCase),
    act: (bloc) => bloc.add(
      ProfileBasicDataUpdateSubmitted(
        ProfileLocalData(
          name: 'أحمد',
          bloodType: 'A+',
          stateId: 100,
          districtId: 1001,
        ),
      ),
    ),
    verify: (bloc) {
      expect(repo.lastBasicPatch?.stateId, 100);
      expect(repo.lastBasicPatch?.districtId, 1001);
      expect(bloc.state, isA<ProfileGetData>());
    },
  );

  blocTest<ProfileBloc, ProfileState>(
    'ProfileImageUploadRequested sets image file id',
    build: () => ProfileBloc(profileUseCase: useCase),
    act: (bloc) => bloc.add(
      ProfileImageUploadRequested(File('/tmp/x.jpg')),
    ),
    verify: (bloc) {
      expect(bloc.state, isA<ProfileSuccess>());
      expect(repo.donor.image, '42');
    },
  );
}
