import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../session/session_lifecycle.dart';
import '../../data/datasources/local/preferences_local_datasource.dart';
import '../../data/datasources/local/session_local_datasource.dart';
import 'api_endpoints.dart';
import 'auth_token_interceptor.dart';
import 'device_id_interceptor.dart';

/// Refreshes JWT once on 401 and retries; dedupes concurrent refresh calls.
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required Dio mainDio,
    required Dio refreshDio,
    required SessionLocalDataSource session,
    required SessionLifecycle lifecycle,
  })  : _dio = mainDio,
        _refreshDio = refreshDio,
        _session = session,
        _lifecycle = lifecycle;

  final Dio _dio;
  final Dio _refreshDio;
  final SessionLocalDataSource _session;
  final SessionLifecycle _lifecycle;

  Future<String?>? _inFlight;

  static bool _isAuthRefreshExemptPath(String path) {
    return path.contains(ApiEndpoints.authRefresh) ||
        path.contains(ApiEndpoints.authLogin) ||
        path.contains(ApiEndpoints.authRegister);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (_isAuthRefreshExemptPath(path)) {
      await _session.clearSession();
      _lifecycle.notifySessionExpired();
      handler.next(err);
      return;
    }

    try {
      final newAccess = await _refreshOrAwait();
      if (newAccess == null) {
        await _session.clearSession();
        _lifecycle.notifySessionExpired();
        handler.next(err);
        return;
      }
      final clone = err.requestOptions;
      clone.headers['Authorization'] = 'Bearer $newAccess';
      final response = await _dio.fetch(clone);
      handler.resolve(response);
    } catch (_) {
      await _session.clearSession();
      _lifecycle.notifySessionExpired();
      handler.next(err);
    }
  }

  Future<String?> _refreshOrAwait() {
    if (_inFlight != null) {
      return _inFlight!;
    }
    final future = _performRefresh();
    _inFlight = future;
    future.whenComplete(() {
      _inFlight = null;
    });
    return future;
  }

  Future<String?> _performRefresh() async {
    final refresh = await _session.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      return null;
    }
    try {
      final res = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refresh},
      );
      final status = res.statusCode ?? 0;
      if (status != 201 && status != 200) {
        return null;
      }
      final data = res.data;
      final access = data?['accessToken'] as String?;
      if (access == null || access.isEmpty) {
        return null;
      }
      await _session.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );
      return access;
    } catch (_) {
      return null;
    }
  }
}

final BaseOptions _baseOptions = BaseOptions(
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
  headers: {'Accept': 'application/json'},
  contentType: 'application/json',
);

/// Wires Dio with device id, Bearer token injection, and 401 refresh.
Dio createAppDio({
  required PreferencesLocalDataSource prefs,
  required SessionLocalDataSource session,
  required SessionLifecycle lifecycle,
}) {
  final dio = Dio(
    _baseOptions.copyWith(baseUrl: AppConfig.apiBaseUrl),
  );

  final refreshDio = Dio(
    _baseOptions.copyWith(baseUrl: AppConfig.apiBaseUrl),
  );
  refreshDio.interceptors.add(DeviceIdInterceptor(prefs));

  dio.interceptors.addAll([
    DeviceIdInterceptor(prefs),
    AuthTokenInterceptor(session),
    AuthRefreshInterceptor(
      mainDio: dio,
      refreshDio: refreshDio,
      session: session,
      lifecycle: lifecycle,
    ),
  ]);

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  return dio;
}
