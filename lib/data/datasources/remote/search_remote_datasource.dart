import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
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

  int _readStock(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  BloodCenter _centerFromJson(Map<String, dynamic> json) {
    final stock = json['bloodStock'];
    final stockMap =
        stock is Map ? Map<String, dynamic>.from(stock) : <String, dynamic>{};

    final stateObj = json['state'];
    final districtObj = json['district'];
    String locationName(dynamic obj) {
      if (obj is! Map) return '';
      final m = Map<String, dynamic>.from(obj);
      return m['nameAr']?.toString() ?? m['name']?.toString() ?? '';
    }

    return BloodCenter(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: '',
      phone: json['phone']?.toString() ?? '',
      state: locationName(stateObj),
      district: locationName(districtObj),
      neighborhood: json['locationName']?.toString() ?? '',
      image: json['imageUrl']?.toString() ?? '',
      lastUpdate: json['updatedAt']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      lon: json['lon']?.toString() ?? '',
      token: '',
      status: '1',
      aPlus: _readStock(stockMap, 'A+'),
      aMinus: _readStock(stockMap, 'A-'),
      bPlus: _readStock(stockMap, 'B+'),
      bMinus: _readStock(stockMap, 'B-'),
      abPlus: _readStock(stockMap, 'AB+'),
      abMinus: _readStock(stockMap, 'AB-'),
      oPlus: _readStock(stockMap, 'O+'),
      oMinus: _readStock(stockMap, 'O-'),
    );
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
      return list.map(_centerFromJson).toList(growable: false);
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
