// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nabdh_alyaman/core/extensions/extension.dart';
import '../../../core/check_active.dart';
import '../../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../../presentation/pages/setting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../core/error/failures.dart';
import '../../../domain/usecases/reset_password_use_case.dart';
import '../../../domain/usecases/sign_in_usecase.dart';

part 'signin_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required this.signInUseCase,
    required this.resetPasswordUseCase,
  }) : super(SignInInitial());

  final SignInUseCase signInUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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

  Future<void> signInWithPhoneNumber({
    required String phone,
    required Function onVerificationSent,
  }) async {
    emit(SignInLoading());
    try {
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
          verify(smsCode: "123456");
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

  verify({required String smsCode}) async {
    // Save verification ID and resend token to use later
    String smsCode = '123456'; // Replace with the code entered by the user
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verifId,
      smsCode: smsCode,
    );
    // Sign in the user with the verification code
    await _firebaseAuth.signInWithCredential(credential).then((value) {
      print(value.user != null);
      if (value.user != null) {
        emit(SignInSuccess());
      } else {
        emit(SignInFailure(error: "verification failed no user"));
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
    return await FirebaseMessaging.instance.getToken() ?? "";
  }
}
