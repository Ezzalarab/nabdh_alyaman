// ignore_for_file: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nabdh_alyaman/domain/entities/global_app_data.dart';

import '../../../domain/usecases/get_global_data_uc.dart';

part 'global_state.dart';

class GlobalCubit extends Cubit<GlobalState> {
  GlobalCubit({
    required this.getGlobalDataUC,
    // required this.appData,
  }) : super(GlobalInitial());
  final GetGlobalDataUC getGlobalDataUC;
  GlobalAppData? appData;

  Future<void> getGlobalData() async {
    try {
      getGlobalDataUC.call().then((appDataOrFailure) {
        appDataOrFailure.fold((failure) {
          emit(GlobalStateFailure());
        }, (data) {
          appData = data;
          emit(GlobalStateSuccess(
            appData: data,
          ));
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
