// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'global_cubit.dart';

abstract class GlobalState {
  const GlobalState();
}

class GlobalInitial extends GlobalState {}

class GlobalStateSuccess extends GlobalState {
  final GlobalAppData appData;
  const GlobalStateSuccess({
    required this.appData,
  });
}

class GlobalStateFailure extends GlobalState {}
