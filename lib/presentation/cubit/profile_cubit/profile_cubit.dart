// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/usecases/profile_use_case.dart';
import '../../../presentation/widgets/setting/profile_body.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/blood_center.dart';
import '../../../domain/entities/donor.dart';
import '../../../presentation/pages/profile_center.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileUseCase profileUseCase;
  ProfileCubit({
    required this.profileUseCase,
  }) : super(ProfileInitial());
  Donor? currentDonor;
  BloodCenter? currentBloodCenter;

  Future<void> getDataToProfilePage() async {
    try {
      emit(ProfileLoadingBeforFetch());

      await profileUseCase.call().then((donorOrFailure) {
        donorOrFailure.fold(
            (failure) =>
                emit(ProfileFailure(error: getFailureMessage(failure))),
            (donor) => emit(ProfileGetData(donors: donor)));
      });
      // User? currentUser = _auth.currentUser;
      // if (currentUser != null) {
      //   await _fireStore
      //       .collection('donors')
      //       .doc("9U74upZiSOJugT9wrDnu")
      //       .get()
      //       .then((value) async {
      //     donors = Donor.fromMap(value.data()!);
      //     emit(ProfileGetData(donors: donors!));
      //   });
      // } else {
      //   emit(ProfileFailure(error: "tttt"));
      // }
    } catch (e) {
      emit(ProfileFailure(error: "pppppppppppp"));
    }
  }

  Future<void> sendDataProfileSectionOne(
      ProfileLocalData profileLocalData) async {
    try {
      emit(ProfileLoading());

      await profileUseCase
          .callsendDataSectionOne(profileLocalData: profileLocalData)
          .then((sendDataOrFailure) {
        sendDataOrFailure.fold(
            (failure) =>
                emit(ProfileFailure(error: getFailureMessage(failure))),
            (r) => emit(ProfileSuccess()));
        getDataToProfilePage();
      });
      // User? currentUser = _auth.currentUser;

      // if (currentUser != null) {
      //   await _fireStore
      //       .collection('donors')
      //       .doc("9U74upZiSOJugT9wrDnu")
      //       .update({
      //     DonorFields.isGpsOn: profileLocalData.isGpsOn,
      //     DonorFields.isShown: profileLocalData.isShown,
      //     DonorFields.isShownPhone: profileLocalData.isShownPhone,
      //     DonorFields.brithDate: profileLocalData.date,
      //   }).then((value) async {
      //     emit(ProfileSuccess());
      //     getDataToProfilePage();
      //   });
      // } else {
      //   emit(ProfileFailure(
      //       error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
      // }
    } catch (e) {
      emit(ProfileFailure(
          error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
    }
  }

  Future<void> sendBasicDataProfileSectionOne(
      ProfileLocalData profileLocalData) async {
    try {
      emit(ProfileLoading());

      await profileUseCase
          .callsendBasicDataProfileSectionOne(
              profileLocalData: profileLocalData)
          .then((sendDataOrFailure) {
        sendDataOrFailure.fold(
            (failure) =>
                emit(ProfileFailure(error: getFailureMessage(failure))),
            (r) => emit(ProfileSuccess()));
        getDataToProfilePage();
      });
      // User? currentUser = _auth.currentUser;
      // if (currentUser != null) {
      //   await _fireStore
      //       .collection('donors')
      //       .doc("9U74upZiSOJugT9wrDnu")
      //       .update({
      //     DonorFields.name: profileLocalData.name,
      //     DonorFields.bloodType: profileLocalData.bloodType,
      //     DonorFields.state: profileLocalData.state,
      //     DonorFields.district: profileLocalData.district,
      //     DonorFields.neighborhood: profileLocalData.neighborhood,
      //   }).then((value) async {
      //     emit(ProfileSuccess());
      //     getDataToProfilePage();
      //   });

      // } else {
      //   emit(ProfileFailure(
      //       error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
      // }
    } catch (e) {
      emit(ProfileFailure(
          error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
    }
  }

  Future<void> getProfileCenterData() async {
    try {
      emit(ProfileLoadingBeforFetch());
      await profileUseCase.callCenterData().then((bloodCenterOrFailur) {
        bloodCenterOrFailur.fold(
            (failure) =>
                emit(ProfileFailure(error: getFailureMessage(failure))),
            (bloodCenter) =>
                emit(ProfileGetCenterData(bloodCenter: bloodCenter)));
      });
      // User? currentUser = _auth.currentUser;
      // if (currentUser != null) {
      //   await _fireStore
      //       .collection('centers')
      //       .doc("CWTU0qCghsDi132oDsMh")
      //       .get()
      //       .then((value) async {
      //     print(";;;;;;;;;;;;;;;;;;;;;;;;;");
      //     bloodCenter = BloodCenter.fromMap(value.data()!);
      //     print(bloodCenter!.name);
      //     emit(ProfileGetCenterData(bloodCenter: bloodCenter!));
      //   });

      // } else {
      //   emit(ProfileFailure(error: "tttt"));
      // }
    } catch (e) {
      emit(ProfileFailure(error: "pppppppppppp"));
    }
  }

  Future<void> sendProfileCenterData(
      ProfileCenterData profileCenterData) async {
    try {
      emit(ProfileLoading());
      await profileUseCase
          .callsendProfileCenterData(profileCenterData: profileCenterData)
          .then((sendDataOrFailure) {
        sendDataOrFailure.fold(
            (failure) =>
                emit(ProfileFailure(error: getFailureMessage(failure))),
            (r) => emit(ProfileSuccess()));
        getProfileCenterData();
      });

      // emit(ProfileLoading());
      // User? currentUser = _auth.currentUser;
      // if (currentUser != null) {
      //   await _fireStore
      //       .collection('centers')
      //       .doc("CWTU0qCghsDi132oDsMh")
      //       .update({
      //     BloodCenterField.aPlus: profileCenterData.aPlus,
      //     BloodCenterField.aMinus: profileCenterData.aMinus,
      //     BloodCenterField.abPlus: profileCenterData.abPlus,
      //     BloodCenterField.oPlus: profileCenterData.oPlus,
      //     BloodCenterField.oMinus: profileCenterData.oMinus,
      //     BloodCenterField.bPlus: profileCenterData.bPlus,
      //     BloodCenterField.bMinus: profileCenterData.bMinus,
      //   }).then((value) async {
      //     emit(ProfileSuccess());
      //     getProfileCenterData();
      //   });
      // } else {
      //   emit(ProfileFailure(error: "tttt"));
      // }
    } catch (e) {
      emit(ProfileFailure(error: "pppppppppppp"));
    }
  }

  Future<void> sendBasicCenterDataProfile(
      ProfileCenterData profileCenterData) async {
    try {
      emit(ProfileLoading());

      await profileUseCase
          .callsendBasicCenterDataProfile(profileCenterData: profileCenterData)
          .then((sendDataOrFailure) {
        sendDataOrFailure.fold(
            (failure) =>
                emit(ProfileFailure(error: getFailureMessage(failure))),
            (r) => emit(ProfileSuccess()));
        getProfileCenterData();
      });
      // User? currentUser = _auth.currentUser;
      // if (currentUser != null) {
      //   await _fireStore
      //       .collection('donors')
      //       .doc("9U74upZiSOJugT9wrDnu")
      //       .update({
      //     DonorFields.name: profileLocalData.name,
      //     DonorFields.bloodType: profileLocalData.bloodType,
      //     DonorFields.state: profileLocalData.state,
      //     DonorFields.district: profileLocalData.district,
      //     DonorFields.neighborhood: profileLocalData.neighborhood,
      //   }).then((value) async {
      //     emit(ProfileSuccess());
      //     getDataToProfilePage();
      //   });

      // } else {
      //   emit(ProfileFailure(
      //       error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
      // }
    } catch (e) {
      emit(ProfileFailure(
          error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
    }
  }
}
