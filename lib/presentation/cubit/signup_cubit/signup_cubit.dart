// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/blood_center.dart';
import '../../../domain/usecases/sign_up_center_usecase.dart';
import '../../../domain/usecases/sign_up_donor_usecase.dart';
import '../../../domain/entities/donor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'signup_state.dart';

class SignUpCubit extends Cubit<SignupState> {
  SignUpCubit({
    required this.signUpDonorUseCase,
    required this.signUpCenterUseCase,
  }) : super(SignupInitial());
  FirebaseAuth fireAuth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  User? currentUser;
  final SignUpDonorUseCase signUpDonorUseCase;
  final SignUpCenterUseCase signUpCenterUseCase;

  Future<void> signUpDonor({
    required Donor donor,
  }) async {
    emit(SignupLoading());
    try {
      donor.token = await getToken();
      await signUpDonorUseCase(donor: donor).then((value) {
        value.fold(
            (failure) =>
                emit(SignUpFailure(error: _getFailureMessage(failure))),
            (userCredential) => emit(SignUpSuccess()));
      });
    } catch (e) {
      emit(SignUpFailure(error: e.toString()));
    }
  }

  Future<void> signUpCenter({
    required BloodCenter center,
  }) async {
    emit(SignupLoading());
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
