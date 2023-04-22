part of 'signin_cubit.dart';

@immutable
abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {}

class SignInSuccessResetPass extends SignInState {}

class SigninFailure extends SignInState {
  final String error;
  SigninFailure({required this.error});
}
