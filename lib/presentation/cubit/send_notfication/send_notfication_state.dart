part of 'send_notfication_cubit.dart';

abstract class SendNotficationState {
  const SendNotficationState();
}

class SendNotficationInitial extends SendNotficationState {}

class SendNotficationStateSuccess extends SendNotficationState {}

class SendNotficationStateFailure extends SendNotficationState {}
