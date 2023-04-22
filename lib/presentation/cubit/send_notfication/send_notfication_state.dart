part of 'send_notfication_cubit.dart';

abstract class SendNotficationState extends Equatable {
  const SendNotficationState();

  @override
  List<Object> get props => [];
}

class SendNotficationInitial extends SendNotficationState {}

class SendNotficationStateSuccess extends SendNotficationState {}

class SendNotficationStateFailure extends SendNotficationState {}
