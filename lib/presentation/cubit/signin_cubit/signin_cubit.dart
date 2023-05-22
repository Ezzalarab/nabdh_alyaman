import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../core/error/failures.dart';
import '../../../core/extensions/extension.dart';
import '../../../core/utils.dart';
import '../../../domain/entities/donor.dart';
import '../../../domain/usecases/reset_password_use_case.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import '../../../presentation/pages/setting_page.dart';

part 'signin_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required this.signInUseCase,
    required this.resetPasswordUseCase,
  }) : super(SignInInitial());

  final SignInUseCase signInUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  late String verifId;

  Future<void> signIn({
    required String emailOrPhone,
    required String password,
    required Function onVerificationSent,
  }) async {
    if (emailOrPhone.isValidPhoneWithKeyCode) {
      String phoneWithKey = emailOrPhone;
      await signInWithPhoneNumber(
        phone: phoneWithKey,
        onVerificationSent: onVerificationSent,
      );
    } else if (emailOrPhone.isValidPhone) {
      String phoneWithKey = "+967$emailOrPhone";
      await signInWithPhoneNumber(
        phone: phoneWithKey,
        onVerificationSent: onVerificationSent,
      );
    } else if (emailOrPhone.isValidEmail) {
      String email = emailOrPhone;
      await signInWithEmail(email: email, password: password);
    } else {
      emit(SignInFailure(error: "Not a phone, not an email"));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());
    try {
      await signInUseCase(email: email, password: password)
          .then((userCredentialOrFailure) {
        userCredentialOrFailure.fold(
          (failure) => emit(SignInFailure(error: getFailureMessage(failure))),
          (userCredential) async {
            await updateToken(userCredential.user!.uid);
            // await CheckActive.checkActiveUser();
            emit(SignInSuccess());
          },
        );
      });
    } catch (e) {
      emit(SignInFailure(error: e.toString()));
    }
  }

  Future<bool> hasData(String phone) async {
    return await _fireStore
        .collection(DonorFields.collectionName)
        .where(DonorFields.phone, isEqualTo: phone)
        .get()
        .then((res) => (res.docs.isNotEmpty));
  }

  Future<void> signInWithPhoneNumber({
    required String phone,
    required Function onVerificationSent,
  }) async {
    emit(SignInLoading());
    try {
      if (!await hasData(Utils.removeCountryKeyFormPhone(phone))) {
        emit(SignInFailure(error: "ليس لديك حساب، قم بإنشاء حساب أولاً"));
        return;
      }
      // Request verification code for the provided phone number
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically sign in the user if verification is completed without user input
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("firebaseAuthException");
          print(e.message);
          emit(SignInFailure(
              error: e.message ?? "Sign in with phone verification failed"));
        },
        codeSent: (String verificationId, int? resendToken) async {
          verifId = verificationId;
          onVerificationSent();
          emit(SignInInitial());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout for automatic code retrieval
          emit(
              SignInFailure(error: "Sign in with phone verification time out"));
        },
      );
    } catch (e) {
      emit(SignInFailure(error: e.toString()));
    }
  }

  Future<void> verify({required String smsCode}) async {
    emit(SignInLoading());
    try {
      // Save verification ID and resend token to use later
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verifId,
        smsCode: smsCode,
      );
      // Sign in the user with the verification code
      await _firebaseAuth.signInWithCredential(credential).then((value) {
        if (value.user != null) {
          Hive.box(dataBoxName).put('user', "1");
          increaseUsersToday();
          emit(SignInSuccess());
        } else {
          emit(SignInFailure(error: "verification failed no user"));
        }
      });
    } on FirebaseException catch (fireError) {
      print("fireError.code");
      print(fireError.code);
      if (fireError.code == 'invalid-verification-code') {
        emit(SignInFailure(error: "رمز التأكيد خطأ، حاول مرة أخرى."));
      } else {
        emit(SignInFailure(error: fireError.code));
      }
    } catch (e) {
      print(e);
      emit(SignInFailure(error: e.toString()));
    }
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

  Future<void> updateToken(String uid) async {
    String userType = Hive.box(dataBoxName).get('user') ?? "0";
    print(userType);
    String collectionName = userType == "1" ? "donors" : "centers";
    String token = await FirebaseMessaging.instance
        .getToken()
        .then((value) => value.toString());
    print(token);
    FirebaseFirestore.instance.collection(collectionName).doc(uid).update({
      "token": token,
    });
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    emit(SignInLoading());
    try {
      await resetPasswordUseCase(email: email).then((unitOrFailuer) {
        unitOrFailuer.fold(
          (failure) => emit(SignInFailure(error: getFailureMessage(failure))),
          (_) => emit(SignInSuccessResetPass()),
        );
      });
    } catch (e) {
      emit(SignInFailure(error: "تحقق من صحة بريدك الالكتروني"));
    }
  }

  Future<String> getToken() async {
    return FirebaseMessaging.instance.getToken().toString();
  }
}
