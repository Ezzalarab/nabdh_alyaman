import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../models/cached_location_row.dart';

abstract class LocationsRemoteDataSource {
  Future<List<CachedLocationState>> fetchStates();

  Future<List<CachedLocationDistrict>> fetchDistricts(int stateId);
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  LocationsRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map<String, dynamic>) {
      final raw = data['items'] ??
          data['data'] ??
          data['locations'] ??
          data['states'] ??
          data['districts'];
      if (raw is List) {
        return raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false);
      }
    }
    return [];
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  String? _asString(dynamic v) => v?.toString();

  @override
  Future<List<CachedLocationState>> fetchStates() async {
    try {
      final res = await _api.get<dynamic>(ApiEndpoints.locationsStates);
      final list = _extractList(res.data);
      final out = <CachedLocationState>[];
      for (final m in list) {
        final id =
            _asInt(m['stateId']) ?? _asInt(m['id']);
        final name =
            _asString(m['nameAr']) ??
                _asString(m['name']) ??
                _asString(m['title']);
        if (id != null && name != null) {
          out.add(CachedLocationState(stateId: id, nameAr: name));
        }
      }
      return out;
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<List<CachedLocationDistrict>> fetchDistricts(int stateId) async {
    try {
      final res =
          await _api.get<dynamic>(ApiEndpoints.locationsDistricts(stateId));
      final list = _extractList(res.data);
      final out = <CachedLocationDistrict>[];
      for (final m in list) {
        final did =
            _asInt(m['districtId']) ?? _asInt(m['id']);
        final sid = _asInt(m['stateId']) ?? stateId;
        final name =
            _asString(m['nameAr']) ??
                _asString(m['name']) ??
                _asString(m['title']);
        if (did != null && name != null) {
          out.add(
            CachedLocationDistrict(
              districtId: did,
              stateId: sid,
              nameAr: name,
            ),
          );
        }
      }
      return out;
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
