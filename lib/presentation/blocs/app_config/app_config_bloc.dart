import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/app_version.dart';
import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/app_update_policy.dart';
import '../../../domain/entities/global_app_data.dart';
import '../../../domain/usecases/load_app_config_uc.dart';

part 'app_config_event.dart';
part 'app_config_state.dart';

class _VersionResolution {
  const _VersionResolution({required this.version, required this.usedFallback});

  final String version;
  final bool usedFallback;
}

class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {
  AppConfigBloc({
    required LoadAppConfigUseCase loadAppConfig,
    Future<String> Function()? currentVersionProvider,
  })  : _loadAppConfig = loadAppConfig,
        _currentVersionProvider =
            currentVersionProvider ?? _readPlatformVersion,
        super(AppConfigInitial()) {
    on<AppConfigLoadRequested>(_onLoad);
    on<AppVersionCheckRequested>(_onVersionCheck);
  }

  final LoadAppConfigUseCase _loadAppConfig;
  final Future<String> Function() _currentVersionProvider;

  GlobalAppData? _cachedData;
  AppUpdatePolicy _cachedPolicy = AppUpdatePolicy.empty;
  bool _lastVersionUsedFallback = false;

  GlobalAppData get data => _cachedData ?? LocalData.initialAppData;

  Future<void> _onLoad(
    AppConfigLoadRequested event,
    Emitter<AppConfigState> emit,
  ) async {
    emit(AppConfigLoading());
    final resolved = await _resolveCurrentVersion();
    _lastVersionUsedFallback = resolved.usedFallback;
    final result = await _loadAppConfig(currentVersion: resolved.version);
    result.fold(
      (_) {
        _cachedData = LocalData.initialAppData;
        _cachedPolicy = AppUpdatePolicy.empty;
        emit(AppConfigFailure(data: data));
      },
      (bundle) {
        _cachedData = bundle.data;
        _cachedPolicy = bundle.updatePolicy;
        if (bundle.updatePolicy.shouldPrompt) {
          emit(
            AppUpdateRequired(policy: bundle.updatePolicy, data: bundle.data),
          );
        } else {
          emit(
            AppConfigLoaded(
              data: bundle.data,
              updatePolicy: bundle.updatePolicy,
              usedFallback: _lastVersionUsedFallback,
            ),
          );
        }
      },
    );
  }

  Future<void> _onVersionCheck(
    AppVersionCheckRequested event,
    Emitter<AppConfigState> emit,
  ) async {
    if (_cachedData == null) {
      add(AppConfigLoadRequested());
      return;
    }
    if (_cachedPolicy.shouldPrompt) {
      emit(AppUpdateRequired(policy: _cachedPolicy, data: _cachedData!));
    } else {
      emit(
        AppConfigLoaded(
          data: _cachedData!,
          updatePolicy: _cachedPolicy,
          usedFallback: _lastVersionUsedFallback,
        ),
      );
    }
  }

  Future<_VersionResolution> _resolveCurrentVersion() async {
    try {
      final version = await _currentVersionProvider();
      return _VersionResolution(version: version, usedFallback: false);
    } catch (error, stackTrace) {
      _logVersionReadFailure(error, stackTrace);
      return _VersionResolution(
        version: kAppVersionFallback,
        usedFallback: true,
      );
    }
  }

  static void _logVersionReadFailure(Object error, StackTrace stackTrace) {
    developer.log(
      'PackageInfo/currentVersionProvider failed; using fallback '
      '$kAppVersionFallback. Force-update checks may be inaccurate.',
      name: 'nabdh_alyaman.app_config',
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  static Future<String> _readPlatformVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}
