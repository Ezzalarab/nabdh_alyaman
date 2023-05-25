// ignore_for_file: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/usecases/get_global_data_uc.dart';

part 'global_state.dart';

class GlobalCubit extends Cubit<GlobalState> {
  GlobalCubit({
    required this.getGlobalDataUC,
  }) : super(GlobalInitial());
  final GetGlobalDataUC getGlobalDataUC;

  Future<void> getGlobalData() async {
    try {
      getGlobalDataUC.call().then((sendNotficationOrFailure) {
        sendNotficationOrFailure.fold((failure) {
          emit(GlobalStateFailure());
        }, (right) {
          emit(GlobalStateSuccess());
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
