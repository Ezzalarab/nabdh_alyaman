import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../models/center_profile_dto.dart';

abstract class CenterRemoteDataSource {
  Future<CenterProfileDto> getMe();

  Future<CenterProfileDto> patchMe(Map<String, dynamic> body);

  Future<CenterStockAdjustResult> adjustStock({
    required String bloodType,
    required int change,
    String? reason,
  });

  Future<CenterDonationResult> recordDonation({
    required int donorId,
    String? notes,
  });

  Future<CenterStockHistoryPage> getStockHistory({
    String? cursor,
    int? limit,
  });
}

class CenterRemoteDataSourceImpl implements CenterRemoteDataSource {
  CenterRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  CenterProfileDto _parseProfile(dynamic data) {
    if (data is! Map) {
      throw WrongDataFailure();
    }
    return CenterProfileDto.fromJson(Map<String, dynamic>.from(data));
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final raw = data['items'] ?? data['data'] ?? data['history'];
      if (raw is List) {
        return raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false);
      }
    }
    return [];
  }

  @override
  Future<CenterProfileDto> getMe() async {
    try {
      final res = await _api.get<dynamic>(ApiEndpoints.centersMe);
      if (res.statusCode != 200 || res.data == null) {
        throw WrongDataFailure();
      }
      return _parseProfile(res.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<CenterProfileDto> patchMe(Map<String, dynamic> body) async {
    try {
      final res = await _api.patch<dynamic>(
        ApiEndpoints.centersMe,
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

  @override
  Future<CenterStockAdjustResult> adjustStock({
    required String bloodType,
    required int change,
    String? reason,
  }) async {
    try {
      final res = await _api.patch<dynamic>(
        ApiEndpoints.centersMeStock,
        data: {
          'bloodType': bloodType,
          'change': change,
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      );
      if (res.statusCode != 200 || res.data == null) {
        throw WrongDataFailure();
      }
      final map = res.data is Map
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};
      return CenterStockAdjustResult.fromJson(map);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<CenterDonationResult> recordDonation({
    required int donorId,
    String? notes,
  }) async {
    try {
      final res = await _api.post<dynamic>(
        ApiEndpoints.centersMeDonations,
        data: {
          'donorId': donorId,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      if (res.statusCode != 201 && res.statusCode != 200) {
        throw WrongDataFailure();
      }
      if (res.data is Map) {
        return CenterDonationResult.fromJson(
          Map<String, dynamic>.from(res.data as Map),
        );
      }
      return CenterDonationResult();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<CenterStockHistoryPage> getStockHistory({
    String? cursor,
    int? limit,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        ApiEndpoints.centersMeStockHistory,
        queryParameters: {
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      if (res.statusCode != 200) {
        throw WrongDataFailure();
      }
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final items = _extractList(data)
            .map(CenterStockHistoryEntry.fromJson)
            .toList(growable: false);
        return CenterStockHistoryPage(
          items: items,
          nextCursor: data['nextCursor']?.toString(),
          hasNextPage: data['hasNextPage'] == true,
        );
      }
      final list = _extractList(data)
          .map(CenterStockHistoryEntry.fromJson)
          .toList(growable: false);
      return CenterStockHistoryPage(items: list);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
