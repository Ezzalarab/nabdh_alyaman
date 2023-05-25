part of 'global_cubit.dart';

abstract class GlobalState extends Equatable {
  const GlobalState();

  @override
  List<Object> get props => [];
}

class GlobalInitial extends GlobalState {}

class GlobalStateSuccess extends GlobalState {}

class GlobalStateFailure extends GlobalState {}
