import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../presentation/pages/setting_page.dart';
import '../../../core/utils.dart';
import '../../../domain/usecases/sign_up_donor_data_uc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/blood_center.dart';
import '../../../domain/entities/donor.dart';
import '../../../domain/usecases/sign_up_center_usecase.dart';
import '../../../domain/usecases/sign_up_donor_auth_uc.dart';

part 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({
    required this.signUpDonorAuthUseCase,
    required this.saveDonorDataUC,
    required this.signUpCenterUseCase,
  }) : super(SignUpInitial(canSignUpWithPhone: false));

  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  User? currentUser;
  final SignUpDonorAuthUseCase signUpDonorAuthUseCase;
  final SignUpDonorDataUseCase saveDonorDataUC;
  final SignUpCenterUseCase signUpCenterUseCase;
  bool canSignUpWithPhone = false;
  String? _verificationId;
  late UserCredential _currentUserCredential;

  Future<void> checkCanSignUpWithPhone() async {
    emit(SignUpLoading());
    String today = Utils.getCurrentDate();
    bool areUsers40Today = true;
    await _fireStore
        .collection("users_per_day")
        .doc(today)
        .get()
        .then((value) async {
      if (value.exists) {
        int usersCount = await value.get("users_count") ?? 0;
        print(usersCount);
        if (usersCount >= 40) {
          areUsers40Today = false;
        }
      } else {
        await FirebaseFirestore.instance
            .collection("users_per_day")
            .doc(today)
            .set({
          "users_count": 1,
        });
      }
    });
    print(areUsers40Today);
    canSignUpWithPhone = areUsers40Today;
    emit(SignUpInitial(canSignUpWithPhone: areUsers40Today));
  }

  Future<void> increaseUsersToday() async {
    String today = Utils.getCurrentDate();
    await _fireStore
        .collection("users_per_day")
        .doc(today)
        .get()
        .then((value) async {
      if (value.exists) {
        int usersCount = await value.get("users_count") ?? 0;
        await _fireStore
            .collection("users_per_day")
            .doc(today)
            .set({"users_count": usersCount + 1});
      }
    });
  }

  Future<void> signUpAuthDonor({
    required Donor donor,
    required Function onVerificationSent,
  }) async {
    if (canSignUpWithPhone) {
      signUpDonorWithPhone(
        phone: donor.phone,
        onVerificationSent: onVerificationSent,
      );
    } else {
      signUpDonorWithEmail(donor: donor);
    }
  }

  Future<void> signUpDonorWithPhone({
    required String phone,
    required Function onVerificationSent,
  }) async {
    print("start phone verification ==-==-==-=-=-=");
    emit(SignUpLoading());
    // Checking if phone number is registered in other account
    String phonePreviousUserName = await checkIsPhoneRegistered(phone);
    if (phonePreviousUserName != "") {
      emit(SignUpFailure(
          error:
              'الرقم مستخدم باسم: $phonePreviousUserName، قم بتسجيل الدخول.'));
      return;
    }
    // Signing with phone
    await _fireAuth
        .verifyPhoneNumber(
      phoneNumber: "+967$phone",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _fireAuth.signInWithCredential(credential);
        print("_phone");
        print(phone);
      },
      verificationFailed: (FirebaseException e) {
        print("verificationFailed");
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        emit(SignUpInitial(canSignUpWithPhone: canSignUpWithPhone));
        print("verificationId");
        print(verificationId);
        _verificationId = verificationId;
        onVerificationSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    )
        .catchError((e) {
      print("firebase error -------------");
      print(e);
    });
  }

  Future<String> checkIsPhoneRegistered(String phone) async {
    return _fireStore
        .collection(DonorFields.collectionName)
        .where('phone', isEqualTo: phone)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        return "";
      } else {
        return value.docs.first.get('name');
      }
    });
  }

  Future<void> verify({
    required BuildContext context,
    required String smsCode,
  }) async {
    try {
      emit(SignUpLoading());
      Navigator.of(context).pop();
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _fireAuth
          .signInWithCredential(phoneAuthCredential)
          .then((userCredential) async {
        if (userCredential.user != null) {
          print("userCredential.user!.uid");
          print(userCredential.user!.uid);
          _currentUserCredential = userCredential;
          increaseUsersToday();
          Hive.box(dataBoxName).put('user', "1");
          emit(SignUpAuthSuccess());
        } else {
          SignUpAuthFailure(error: "فشل إنشاء الحساب");
        }
      });
    } on FirebaseException catch (fireError) {
      print("fireError.code");
      print(fireError.code);
      if (fireError.code == 'invalid-verification-code') {
        emit(SignUpFailure(error: "رمز التأكيد خطأ، حاول مرة أخرى."));
      } else {
        emit(SignUpFailure(error: fireError.code));
      }
    } catch (e) {
      print(e);
      emit(SignUpFailure(error: e.toString()));
    }
  }

  Future<void> signUpDonorWithEmail({
    required Donor donor,
  }) async {
    emit(SignUpLoading());
    try {
      donor.token = await getToken();
      await signUpDonorAuthUseCase(donor: donor).then((value) {
        value.fold(
            (failure) =>
                emit(SignUpAuthFailure(error: _getFailureMessage(failure))),
            (userCredential) {
          _currentUserCredential = userCredential;
          Hive.box(dataBoxName).put('user', "1");
          emit(SignUpAuthSuccess());
        });
      });
    } catch (e) {
      emit(SignUpAuthFailure(error: e.toString()));
    }
  }

  Future<void> saveDonorData({
    required Donor donor,
  }) async {
    emit(SignUpLoading());
    try {
      donor.token = await getToken();
      await saveDonorDataUC(
              donor: donor,
              uid: _currentUserCredential.user?.uid.toString() ?? "")
          .then((value) {
        value.fold(
            (failure) =>
                emit(SignUpDataFailure(error: _getFailureMessage(failure))),
            (_) {
          Hive.box(dataBoxName).put('user', "1");
          emit(SignUpDataSuccess());
        });
      });
    } catch (e) {
      emit(SignUpDataFailure(error: e.toString()));
    }
  }

  Future<void> signUpCenter({
    required BloodCenter center,
  }) async {
    emit(SignUpLoading());
    try {
      center.token = await getToken();
      await signUpCenterUseCase(center: center).then((value) {
        value.fold(
            (failure) =>
                emit(SignUpFailure(error: _getFailureMessage(failure))),
            (userCredential) {
          emit(SignUpSuccess());
        });
      });
    } catch (e) {
      emit(SignUpFailure(error: e.toString()));
    }
  }

  Future<String> getToken() async {
    return FirebaseMessaging.instance.getToken().toString();
  }

  String _getFailureMessage(Failure failur) {
    switch (failur.runtimeType) {
      case OffLineFailure:
        return "لا يوجد إنترنت";
      case WrongDataFailure:
        return "تأكد من صحة البيانات المدخلة";
      case InvalidEmailFailure:
        return "البريد الإلكتروني غير صالح";
      case EmailAlreadyRegisteredFailure:
        return "البريد مستخدم من قبل";
      case UnknownFailure:
        return "خطأ غير معروف";
      case FirebaseUnknownFailure:
        return "خطأ من قاعدة البيانات غير معروف";
      default:
        return "خطأ غير معروف";
    }
  }
}
