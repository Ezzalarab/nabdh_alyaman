// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'signup_cubit.dart';

@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {
  final bool canSignUpWithPhone;
  SignUpInitial({
    required this.canSignUpWithPhone,
  });
}

class SignUpLoading extends SignUpState {}

class SignUpAuthSuccess extends SignUpState {}

class SignUpAuthFailure extends SignUpState {
  final String error;
  SignUpAuthFailure({required this.error});
}

class SignUpAuthVerifying extends SignUpState {
  final String code;
  SignUpAuthVerifying({required this.code});
}

class SignUpDataSuccess extends SignUpState {}

class SignUpDataFailure extends SignUpState {
  final String error;
  SignUpDataFailure({required this.error});
}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String error;
  SignUpFailure({required this.error});
}
