import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/donor_registration_params.dart';
import '../../models/auth_tokens_result.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensResult> login({
    required String identifier,
    required String password,
  });

  Future<AuthTokensResult> registerDonor(DonorRegistrationParams p);

  Future<void> logout({
    required String refreshToken,
    required String deviceToken,
  });

  Future<void> registerDevice({
    required String token,
    required String platform,
  });

  /// Always 200 server-side — no-op body.
  Future<void> forgotPassword({required String phone});

  Future<String> verifyOtp({required String phone, required String code});

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  int _normStatus(Response<dynamic>? r) => r?.statusCode ?? 0;

  AuthTokensResult _tokensFrom(Map<String, dynamic> data) {
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      throw WrongDataFailure();
    }
    final role = data['role'] as String?;
    final userMap = data['user'];
    final userRole = userMap is Map ? userMap['role'] as String? : null;
    final userIdDyn = userMap is Map ? userMap['id'] : null;
    final phone = userMap is Map ? userMap['phone'] as String? : null;
    final mappedRole = role ?? userRole;
    final userId =
        userIdDyn == null ? '' : userIdDyn.toString();
    if (mappedRole == null ||
        mappedRole.isEmpty ||
        userId.isEmpty) {
      throw WrongDataFailure();
    }
    return AuthTokensResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      session: AuthenticatedSession(
        userId: userId,
        role: mappedRole,
        phone: phone,
      ),
    );
  }

  @override
  Future<AuthTokensResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authLogin,
        data: {'identifier': identifier, 'password': password},
      );
      final s = _normStatus(res);
      final data = res.data;
      if (s != 201 && s != 200 || data == null) {
        throw WrongDataFailure();
      }
      return _tokensFrom(data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<AuthTokensResult> registerDonor(DonorRegistrationParams p) async {
    final body = <String, dynamic>{
      'fullName': p.fullName,
      'phone': p.phone,
      'password': p.password,
      'bloodType': p.bloodType,
      'gender': p.gender,
      'stateId': p.stateId,
      'districtId': p.districtId,
      'locationId': p.locationId,
    };
    if (p.email != null && p.email!.trim().isNotEmpty) {
      body['email'] = p.email!.trim();
    }
    if (p.lat != null) body['lat'] = p.lat;
    if (p.lon != null) body['lon'] = p.lon;

    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: body,
      );
      final s = _normStatus(res);
      final data = res.data;
      if (s != 201 && s != 200 || data == null) {
        throw WrongDataFailure();
      }
      return _tokensFrom(data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> logout({
    required String refreshToken,
    required String deviceToken,
  }) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authLogout,
        data: {
          'refreshToken': refreshToken,
          'deviceToken': deviceToken,
        },
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authDevice,
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (_) {
      // Ignore device registration failures (non-blocking UX).
    }
  }

  @override
  Future<void> forgotPassword({required String phone}) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authForgotPassword,
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<String> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authVerifyOtp,
        data: {'phone': phone, 'code': code},
      );
      final data = res.data;
      final rt = data?['resetToken'] as String?;
      if (rt == null || rt.isEmpty) throw WrongDataFailure();
      return rt;
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _api.post<Map<String, dynamic>>(
        ApiEndpoints.authResetPassword,
        data: {'resetToken': resetToken, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
