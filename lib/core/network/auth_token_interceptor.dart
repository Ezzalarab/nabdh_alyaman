import 'package:dio/dio.dart';

import '../../data/datasources/local/session_local_datasource.dart';

/// Adds `Authorization` when an access token is stored.
class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._session);

  final SessionLocalDataSource _session;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _session.getAccessToken().then((token) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    });
  }
}
