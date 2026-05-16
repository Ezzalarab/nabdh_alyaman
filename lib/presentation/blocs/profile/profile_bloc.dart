import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/check_active.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/donor.dart';
import '../../../domain/usecases/profile_use_case.dart';
import '../../widgets/setting/profile_body.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Donor profile via REST `GET/PATCH /donors/me`.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileUseCase profileUseCase})
      : _profileUseCase = profileUseCase,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileSectionOneUpdateSubmitted>(_onSectionOne);
    on<ProfileBasicDataUpdateSubmitted>(_onBasicData);
    on<ProfileImageUploadRequested>(_onImageUpload);
  }

  final ProfileUseCase _profileUseCase;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingBeforFetch());
    final result = await _profileUseCase.call();
    result.fold(
      (failure) => emit(ProfileFailure(error: getFailureMessage(failure))),
      (donor) {
        CheckActive.currentDonor = donor;
        emit(ProfileGetData(donors: donor));
      },
    );
  }

  Future<void> _onSectionOne(
    ProfileSectionOneUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _profileUseCase.callsendDataSectionOne(
      profileLocalData: event.data,
    );
    await result.fold(
      (failure) async {
        emit(ProfileFailure(error: getFailureMessage(failure)));
      },
      (_) async {
        emit(ProfileSuccess());
        add(ProfileLoadRequested());
      },
    );
  }

  Future<void> _onImageUpload(
    ProfileImageUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result =
        await _profileUseCase.uploadDonorProfileImage(file: event.file);
    await result.fold(
      (failure) async {
        emit(ProfileFailure(error: getFailureMessage(failure)));
      },
      (donor) async {
        CheckActive.currentDonor = donor;
        emit(ProfileGetData(donors: donor));
        emit(ProfileSuccess());
      },
    );
  }

  Future<void> _onBasicData(
    ProfileBasicDataUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _profileUseCase.callsendBasicDataProfileSectionOne(
      profileLocalData: event.data,
    );
    await result.fold(
      (failure) async {
        emit(ProfileFailure(error: getFailureMessage(failure)));
      },
      (_) async {
        emit(ProfileSuccess());
        add(ProfileLoadRequested());
      },
    );
  }
}
