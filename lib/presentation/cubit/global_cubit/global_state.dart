// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'global_cubit.dart';

abstract class GlobalState extends Equatable {
  const GlobalState();

  @override
  List<Object> get props => [];
}

class GlobalInitial extends GlobalState {}

class GlobalStateSuccess extends GlobalState {
  final GlobalAppData appData;
  GlobalStateSuccess({
    required this.appData,
  });
}

class GlobalStateFailure extends GlobalState {}
