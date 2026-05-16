import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../../domain/entities/blood_request.dart';
import '../../models/blood_request_mapper.dart';

abstract class BloodRequestRemoteDataSource {
  Future<BloodRequest> create(BloodRequestCreateParams params);

  Future<BloodRequestPageResult> fetchList({
    String? bloodType,
    int? stateId,
    String? cursor,
    int? limit,
  });

  Future<BloodRequest> fetchById(String id);

  Future<BloodRequest> updateStatus({
    required String id,
    required String status,
  });
}

class BloodRequestRemoteDataSourceImpl implements BloodRequestRemoteDataSource {
  BloodRequestRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  BloodRequest _mapSingle(dynamic data) {
    if (data is Map<String, dynamic>) {
      return bloodRequestFromApiJson(data);
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['bloodRequest'] ?? map['request'] ?? map['data'];
      if (inner is Map) {
        return bloodRequestFromApiJson(Map<String, dynamic>.from(inner));
      }
      return bloodRequestFromApiJson(map);
    }
    throw WrongDataFailure();
  }

  @override
  Future<BloodRequest> create(BloodRequestCreateParams params) async {
    try {
      final body = <String, dynamic>{
        'bloodType': params.bloodType,
        'locationId': params.locationId,
        'hospitalName': params.hospitalName,
        'lat': params.lat,
        'lon': params.lon,
        'unitsNeeded': params.unitsNeeded,
        'urgency': params.urgency,
        if (params.patientName != null && params.patientName!.trim().isNotEmpty)
          'patientName': params.patientName!.trim(),
      };
      final res = await _api.post<dynamic>(
        ApiEndpoints.bloodRequests,
        data: body,
      );
      if (res.statusCode != 201 && res.statusCode != 200) {
        throw WrongDataFailure();
      }
      return _mapSingle(res.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<BloodRequestPageResult> fetchList({
    String? bloodType,
    int? stateId,
    String? cursor,
    int? limit,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        ApiEndpoints.bloodRequests,
        queryParameters: {
          if (bloodType != null && bloodType.isNotEmpty) 'bloodType': bloodType,
          if (stateId != null) 'stateId': stateId,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      if (res.statusCode != 200) throw WrongDataFailure();
      final data = res.data;
      final items =
          extractBloodRequestItems(data).map(bloodRequestFromApiJson).toList();
      return BloodRequestPageResult(
        items: items,
        nextCursor: bloodRequestNextCursor(data),
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<BloodRequest> fetchById(String id) async {
    try {
      final res = await _api.get<dynamic>(ApiEndpoints.bloodRequestById(id));
      if (res.statusCode != 200) throw WrongDataFailure();
      return _mapSingle(res.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<BloodRequest> updateStatus({
    required String id,
    required String status,
  }) async {
    try {
      final res = await _api.patch<dynamic>(
        ApiEndpoints.bloodRequestStatus(id),
        data: {'status': status},
      );
      if (res.statusCode != 200) throw WrongDataFailure();
      return _mapSingle(res.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
