// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nabdh_alyaman/presentation/widgets/forms/my_button.dart';
import 'package:nabdh_alyaman/presentation/widgets/forms/my_text_form_field.dart';

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

  FirebaseAuth fireAuth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  User? currentUser;
  final SignUpDonorAuthUseCase signUpDonorAuthUseCase;
  final SignUpDonorDataUseCase saveDonorDataUC;
  final SignUpCenterUseCase signUpCenterUseCase;
  bool canSignUpWithPhone = false;

  Future<void> checkCanSignUpWithPhone() async {
    emit(SignUpLoading());
    DateTime dateTime = DateTime.now();
    String today = "${dateTime.year}-${dateTime.month}-20";
    bool areUsers40Today = true;
    await FirebaseFirestore.instance
        .collection("users_per_day")
        .doc(today)
        .get()
        .then((value) async {
      if (value.exists) {
        int usersCount = await value.get("users_count");
        print(usersCount);
        if (usersCount < 40) {
          await FirebaseFirestore.instance
              .collection("users_per_day")
              .doc(today)
              .set({
            "users_count": usersCount + 1,
          });
        } else {
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

  Future<void> signUpAuthDonor({
    required Donor donor,
    required BuildContext context,
  }) async {
    if (canSignUpWithPhone) {
      signUpDonorWithPhone(donor: donor, context: context);
    } else {
      signUpDonorWithEmail(donor: donor);
    }
  }

  Future<void> signUpDonorWithPhone(
      {required Donor donor, required BuildContext context}) async {
    await fetchOtp(context: context, phone: donor.phone);
  }

  Future<void> fetchOtp(
      {required BuildContext context, required String phone}) async {
    String? smsCode;
    print("start phone verification ==-==-==-=-=-=");
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: "+967$phone",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        print("_phone");
        print(phone);
      },
      verificationFailed: (FirebaseException e) {
        print("verificationFailed");
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        print("verificationId");
        print(verificationId);
        AwesomeDialog(
            context: context,
            body: Column(
              children: [
                MyTextFormField(
                  onChange: (value) => smsCode = value,
                ),
                MyButton(
                    title: "verify",
                    onPressed: () async {
                      PhoneAuthCredential phoneAuthCredential =
                          PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: smsCode!,
                      );
                      await FirebaseAuth.instance
                          .signInWithCredential(phoneAuthCredential);
                      Navigator.of(context).pop();
                    })
              ],
            )).show();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    )
        .catchError((e) {
      print("firebase error -------------");
      print(e);
    });
  }

  Future<void> verify(String smsCode) async {}

  Future<void> signUpDonorWithEmail({
    required Donor donor,
  }) async {
    emit(SignUpLoading());
    try {
      donor.token = await getToken();
      await saveDonorDataUC(donor: donor).then((value) {
        value.fold(
            (failure) =>
                emit(SignUpAuthFailure(error: _getFailureMessage(failure))),
            (userCredential) => emit(SignUpAuthSuccess()));
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
      await saveDonorDataUC(donor: donor).then((value) {
        value.fold(
            (failure) =>
                emit(SignUpDataFailure(error: _getFailureMessage(failure))),
            (_) => emit(SignUpDataSuccess()));
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
            (userCredential) => emit(SignUpSuccess()));
      });
    } catch (e) {
      emit(SignUpFailure(error: e.toString()));
    }
  }

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken() ?? "";
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
