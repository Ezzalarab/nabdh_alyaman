// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';

import '../../../domain/entities/notfication_data.dart';
import '../../../domain/usecases/send_notfication_.dart';

part 'send_notfication_state.dart';

class SendNotficationCubit extends Cubit<SendNotficationState> {
  SendNotficationCubit({
    required this.sendNotficationUseCase,
  }) : super(SendNotficationInitial());
  final SendNotficationUseCase sendNotficationUseCase;

  Future<void> sendNotfication(
      {required SendNotificationData sendNotficationData}) async {
    try {
      sendNotficationUseCase
          .call(sendNotficationData: sendNotficationData)
          .then((sendNotficationOrFailure) {
        sendNotficationOrFailure.fold(
            (failure) => emit(SendNotficationStateFailure()),
            (right) => emit(SendNotficationStateSuccess()));
      });
    } catch (e) {}
  }
}
