import 'package:dio/dio.dart';

import '../../data/datasources/local/preferences_local_datasource.dart';

/// Attaches stable [x-device-id] (see `PreferencesLocalDataSource`).
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor(this._prefs);

  final PreferencesLocalDataSource _prefs;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _prefs.getOrCreateDeviceId().then((id) {
      options.headers['x-device-id'] = id;
      handler.next(options);
    });
  }
}
