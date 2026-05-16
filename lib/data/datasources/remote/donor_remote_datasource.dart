import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../models/donor_profile_dto.dart';

abstract class DonorRemoteDataSource {
  Future<DonorProfileDto> getMe();

  Future<DonorProfileDto> patchMe(Map<String, dynamic> body);
}

class DonorRemoteDataSourceImpl implements DonorRemoteDataSource {
  DonorRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  DonorProfileDto _parseProfile(dynamic data) {
    if (data is! Map) {
      throw WrongDataFailure();
    }
    return DonorProfileDto.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<DonorProfileDto> getMe() async {
    try {
      final res = await _api.get<dynamic>(ApiEndpoints.donorsMe);
      if (res.statusCode != 200 || res.data == null) {
        throw WrongDataFailure();
      }
      return _parseProfile(res.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<DonorProfileDto> patchMe(Map<String, dynamic> body) async {
    try {
      final res = await _api.patch<dynamic>(
        ApiEndpoints.donorsMe,
        data: body,
      );
      if (res.statusCode != 200 || res.data == null) {
        throw WrongDataFailure();
      }
      return _parseProfile(res.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
