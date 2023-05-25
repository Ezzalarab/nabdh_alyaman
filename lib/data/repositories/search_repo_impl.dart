// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/entities/blood_center.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/search_repo.dart';

class SearchRepoImpl implements SearchRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final NetworkInfo networkInfo;
  SearchRepoImpl({
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Donor>>> searchDonors({
    required String state,
    required String district,
  }) async {
    if (await networkInfo.isConnected) {
      List<Donor> donors = <Donor>[];
      try {
        return await _fireStore
            .collection(DonorFields.collectionName)
            .where(DonorFields.state, isEqualTo: state)
            // .where(DonorFields.district, isEqualTo: district)
            .get()
            .then((fetchedDonors) async {
          if (fetchedDonors.docs.isNotEmpty) {
            donors =
                fetchedDonors.docs.map((e) => Donor.fromMap(e.data())).toList();
            return Right(donors);
          } else {
            return const Right(<Donor>[]);
          }
        });
      } on FirebaseException catch (fireError) {
        print("Search=Donors====fireError.code");
        print(fireError.code);
        if (fireError.code == 'unknown') {
          return Left(FirebaseUnknownFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          return Left(UnknownFailure());
        }
      } catch (e) {
        print("Search=Donors====exception");
        print(e);
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, List<Donor>>> searchStateDonors({
    required String state,
  }) async {
    print("result");
    if (await networkInfo.isConnected) {
      List<Donor> stateDonors = <Donor>[];
      try {
        return await _fireStore
            .collection(DonorFields.collectionName)
            .where(DonorFields.state, isEqualTo: state)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            print(doc.data());
          }
          if (value.docs.isNotEmpty) {
            stateDonors = value.docs
                .map((donorDoc) => Donor.fromMap(donorDoc.data()))
                .toList();
            List<Donor> availableStateDonors =
                stateDonors.where((donor) => donor.isShown == "1").toList();
            return Right(stateDonors);
          } else {
            return const Right(<Donor>[]);
          }
        });
      } on FirebaseException catch (fireError) {
        print("Search=State=Donors====fireError.code");
        print(fireError.code);
        if (fireError.code == 'unknown') {
          return Left(FirebaseUnknownFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          return Left(UnknownFailure());
        }
      } catch (e) {
        print("Search=State=Donors====exception");
        print(e);
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, List<BloodCenter>>> searchCenters({
    required String state,
    required String district,
  }) async {
    if (await networkInfo.isConnected) {
      List<BloodCenter> centers = <BloodCenter>[];
      try {
        return await _fireStore
            .collection(BloodCenterFields.collectionName)
            .where(BloodCenterFields.state, isEqualTo: state)
            .where(BloodCenterFields.district, isEqualTo: district)
            .get()
            .then((fetchedCenters) async {
          if (fetchedCenters.docs.isNotEmpty) {
            centers = fetchedCenters.docs
                .map((e) => BloodCenter.fromMap(e.data()))
                .toList();
            return Right(centers);
          } else {
            return const Right(<BloodCenter>[]);
          }
        });
      } on FirebaseException catch (fireError) {
        print("Search=Centers====fireError.code");
        print(fireError.code);
        if (fireError.code == 'unknown') {
          return Left(FirebaseUnknownFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          return Left(UnknownFailure());
        }
      } catch (e) {
        print("Search=Centers====exception");
        print(e);
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }
}
