import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';

abstract class AppConfigRemoteDataSource {
  Future<Map<String, dynamic>> fetchConfig();
}

class AppConfigRemoteDataSourceImpl implements AppConfigRemoteDataSource {
  AppConfigRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> fetchConfig() async {
    try {
      final res = await _api.get<dynamic>(ApiEndpoints.appConfig);
      if (res.statusCode != 200 || res.data == null) {
        throw WrongDataFailure();
      }
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data);
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw WrongDataFailure();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
