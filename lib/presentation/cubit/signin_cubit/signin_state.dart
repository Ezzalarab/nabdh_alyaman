part of 'signin_cubit.dart';

@immutable
abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {}

class SignInSuccessResetPass extends SignInState {}

class SignInFailure extends SignInState {
  final String error;
  SignInFailure({required this.error});
}
