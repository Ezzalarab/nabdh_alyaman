part of 'app_config_bloc.dart';

sealed class AppConfigState {}

final class AppConfigInitial extends AppConfigState {}

final class AppConfigLoading extends AppConfigState {}

final class AppConfigLoaded extends AppConfigState {
  AppConfigLoaded({
    required this.data,
    required this.updatePolicy,
    this.usedFallback = false,
  });

  final GlobalAppData data;
  final AppUpdatePolicy updatePolicy;
  final bool usedFallback;
}

final class AppUpdateRequired extends AppConfigState {
  AppUpdateRequired({required this.policy, required this.data});

  final AppUpdatePolicy policy;
  final GlobalAppData data;
}

final class AppConfigFailure extends AppConfigState {
  AppConfigFailure({required this.data});

  final GlobalAppData data;
}
