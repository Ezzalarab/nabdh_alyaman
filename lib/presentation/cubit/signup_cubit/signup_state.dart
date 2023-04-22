// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'signup_cubit.dart';

@immutable
abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignUpSuccess extends SignupState {}

class SignUpFailure extends SignupState {
  final String error;
  SignUpFailure({required this.error});
}
