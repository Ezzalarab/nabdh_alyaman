// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/notfication_data.dart';
import '../../../domain/usecases/send_notfication_.dart';

part 'global_state.dart';

class GlobalCubit extends Cubit<GlobalState> {
  GlobalCubit({
    required this.sendNotficationUseCase,
  }) : super(GlobalInitial());
  final SendNotficationUseCase sendNotficationUseCase;

  Future<void> sendNotfication(
      {required SendNotificationData sendNotficationData}) async {
    try {
      sendNotficationUseCase
          .call(sendNotficationData: sendNotficationData)
          .then((sendNotficationOrFailure) {
        sendNotficationOrFailure.fold((failure) => emit(GlobalStateFailure()),
            (right) => emit(GlobalStateSuccess()));
      });
    } catch (e) {}
  }
}
