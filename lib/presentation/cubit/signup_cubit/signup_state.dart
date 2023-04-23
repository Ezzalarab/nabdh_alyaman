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

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String error;
  SignUpFailure({required this.error});
}
