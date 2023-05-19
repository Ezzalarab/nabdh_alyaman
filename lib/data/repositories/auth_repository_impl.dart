import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nabdh_alyaman/core/encryption.dart';

import '../../../presentation/pages/setting_page.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/auth_repository.dart';
// import '../../core/encryption.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final NetworkInfo networkInfo;
  AuthRepositoryImpl({
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserCredential>> signInWithEmail(
      {required String email, required String password}) async {
    if (await networkInfo.isConnected) {
      try {
        print("email & password");
        print(email);
        print(password);
        return await _firebaseAuth
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((userCredential) async {
          if (userCredential.user != null) {
            await saveUserTypeLocal(userCredential);
            return Right(userCredential);
          } else {
            _firebaseAuth.signInWithPhoneNumber(email);
            print("no user");
            return Left(UnknownFailure());
          }
        });
      } on FirebaseException catch (fireError) {
        print("fireError.code");
        print(fireError.code);
        if (fireError.code == 'user-not-found') {
          return Left(WrongDataFailure());
        } else if (fireError.code == 'wrong-password') {
          return Left(WrongDataFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          return Left(UnknownFailure());
        }
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  Future saveUserTypeLocal(UserCredential userCredential) async {
    final box = Hive.box(dataBoxName);
    String docId = userCredential.user!.uid;
    print(docId);
    await _fireStore
        .collection(BloodCenterFields.collectionName)
        .doc(docId)
        .get()
        .then((value) async {
      if (value.data() == null) {
        await _fireStore
            .collection(DonorFields.collectionName)
            .doc(docId)
            .get()
            .then((value) async {
          if (value.data() == null) {
            box.put('user', "0");
          } else {
            box.put('user', "1");
          }
        });
      } else {
        box.put('user', "2");
      }
    });
    print(box.get("user") ?? "5");
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String email}) async {
    if (await networkInfo.isConnected) {
      try {
        return await _firebaseAuth
            .sendPasswordResetEmail(
          email: email,
        )
            .then((userCredential) async {
          return const Right(unit);
        });
      } on FirebaseException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signUpDonorAuth({
    required Donor donor,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return await _firebaseAuth
            .createUserWithEmailAndPassword(
          email: donor.email,
          password: donor.password,
        )
            .then((userCredential) async {
          if (userCredential.user != null) {
            return (Right(userCredential));
          } else {
            return left(WrongDataFailure());
          }
        });
      } on FirebaseException catch (fireError) {
        print(fireError.code);
        if (fireError.code == 'invalid-email') {
          return Left(InvalidEmailFailure());
        } else if (fireError.code == 'weak-password') {
          return Left(WeekPasswordFailure());
        } else if (fireError.code == 'email-already-in-use') {
          return Left(EmailAlreadyRegisteredFailure());
        } else if (fireError.code == 'unknown') {
          return Left(FirebaseUnknownFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          return Left(UnknownFailure());
        }
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpDonorData({
    required Donor donor,
    required String uid,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        if (uid != "") {
          Map<String, dynamic> donorData = donor.toMap();
          donorData['created_at'] = DateTime.now();
          donorData['password'] = Encryption.encode(donorData['password']);
          return await _fireStore
              .collection('donors')
              .doc(uid)
              .set(donorData)
              .then((_) async {
            return const Right(unit);
          });
        } else {
          print("no current user");
          return left(WrongDataFailure());
        }
      } on FirebaseException catch (fireError) {
        if (fireError.code == 'unknown') {
          return Left(FirebaseUnknownFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          print("fireError.code");
          print(fireError.code);
          return Left(UnknownFailure());
        }
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print("sign up failed");
        print(e);
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpCenter({
    required BloodCenter center,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return await _firebaseAuth
            .createUserWithEmailAndPassword(
          email: center.email,
          password: center.password,
        )
            .then((userCredential) async {
          if (userCredential.user != null) {
            try {
              Map<String, dynamic> centerDate = center.toMap();
              centerDate['password'] =
                  Encryption.encode(centerDate['password']);
              return await _fireStore
                  .collection('centers')
                  .doc(userCredential.user!.uid)
                  .set(center.toMap())
                  .then((_) async {
                Hive.box(dataBoxName).put('user', "2");
                return const Right(unit);
              });
            } on FirebaseException catch (fireError) {
              if (fireError.code == 'unknown') {
                return Left(FirebaseUnknownFailure());
              } else if (fireError.code == 'too-many-request') {
                return Left(ServerFailure());
              } else {
                return Left(UnknownFailure());
              }
            } on ServerException {
              return Left(ServerFailure());
            } catch (e) {
              return Left(UnknownFailure());
            }
          } else {
            return left(WrongDataFailure());
          }
        });
      } on FirebaseException catch (fireError) {
        if (fireError.code == 'invalid-email') {
          return Left(InvalidEmailFailure());
        } else if (fireError.code == 'weak-password') {
          return Left(WeekPasswordFailure());
        } else if (fireError.code == 'email-already-in-use') {
          return Left(EmailAlreadyRegisteredFailure());
        } else if (fireError.code == 'unknown') {
          return Left(FirebaseUnknownFailure());
        } else if (fireError.code == 'too-many-request') {
          return Left(ServerFailure());
        } else {
          return Left(UnknownFailure());
        }
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }
}
