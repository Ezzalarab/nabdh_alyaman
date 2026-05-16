part of 'app_config_bloc.dart';

sealed class AppConfigEvent {}

final class AppConfigLoadRequested extends AppConfigEvent {}

final class AppVersionCheckRequested extends AppConfigEvent {}
