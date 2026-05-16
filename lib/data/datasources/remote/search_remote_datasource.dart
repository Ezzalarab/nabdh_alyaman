import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../models/center_json_mapper.dart';
import '../../models/donor_search_result.dart';
import '../../../domain/entities/blood_center.dart';

abstract class SearchRemoteDataSource {
  Future<List<DonorSearchResult>> searchDonorsGeo({
    required String bloodType,
    required double lat,
    required double lon,
    int? stateId,
    bool includeCompatible = true,
  });

  Future<List<DonorSearchResult>> searchDonorsManual({
    required String bloodType,
    int? stateId,
    int? districtId,
    bool includeCompatible = true,
  });

  Future<List<BloodCenter>> fetchCenters({
    int? stateId,
    int? districtId,
    double? lat,
    double? lon,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final raw = data['items'] ?? data['data'] ?? data['centers'];
      if (raw is List) {
        return raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false);
      }
    }
    return [];
  }

  @override
  Future<List<DonorSearchResult>> searchDonorsGeo({
    required String bloodType,
    required double lat,
    required double lon,
    int? stateId,
    bool includeCompatible = true,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        ApiEndpoints.donorSearch,
        queryParameters: {
          'bloodType': bloodType,
          'lat': lat,
          'lon': lon,
          if (stateId != null) 'stateId': stateId,
          'includeCompatible': includeCompatible,
        },
      );
      final list = _extractList(res.data);
      return list.map(DonorSearchResult.fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<List<DonorSearchResult>> searchDonorsManual({
    required String bloodType,
    int? stateId,
    int? districtId,
    bool includeCompatible = true,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        ApiEndpoints.donorSearchManual,
        queryParameters: {
          'bloodType': bloodType,
          if (stateId != null) 'stateId': stateId,
          if (districtId != null) 'districtId': districtId,
          'includeCompatible': includeCompatible,
          'limit': 100,
        },
      );
      final list = _extractList(res.data);
      return list.map(DonorSearchResult.fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<List<BloodCenter>> fetchCenters({
    int? stateId,
    int? districtId,
    double? lat,
    double? lon,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        ApiEndpoints.centers,
        queryParameters: {
          if (stateId != null) 'stateId': stateId,
          if (districtId != null) 'districtId': districtId,
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
        },
      );
      final list = _extractList(res.data);
      return list.map(bloodCenterFromApiJson).toList(growable: false);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}

/// Best-effort current position for geo search.
Future<Position?> tryCurrentPosition() async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );
  } catch (_) {
    return null;
  }
}
