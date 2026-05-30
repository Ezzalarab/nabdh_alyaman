import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_local_datasource.dart';

class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  SessionLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'role';
  static const _phoneKey = 'phone';
  static const _emailKey = 'email';
  static const _emailMissingKey = 'email_missing';
  static const _emailVerifiedKey = 'email_verified';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<void> saveUserMeta({
    required String userId,
    required String role,
    String? phone,
    String? email,
    bool emailMissing = false,
    bool emailVerified = false,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _roleKey, value: role);
    if (phone != null && phone.isNotEmpty) {
      await _storage.write(key: _phoneKey, value: phone);
    } else {
      await _storage.delete(key: _phoneKey);
    }
    if (email != null && email.isNotEmpty) {
      await _storage.write(key: _emailKey, value: email);
    } else {
      await _storage.delete(key: _emailKey);
    }
    await _storage.write(key: _emailMissingKey, value: emailMissing.toString());
    await _storage.write(
      key: _emailVerifiedKey,
      value: emailVerified.toString(),
    );
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  @override
  Future<String?> getRole() => _storage.read(key: _roleKey);

  @override
  Future<String?> getPhone() => _storage.read(key: _phoneKey);

  @override
  Future<String?> getEmail() => _storage.read(key: _emailKey);

  @override
  Future<bool> getEmailMissing() async {
    final v = await _storage.read(key: _emailMissingKey);
    return v == 'true';
  }

  @override
  Future<bool> getEmailVerified() async {
    final v = await _storage.read(key: _emailVerifiedKey);
    return v == 'true';
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _emailMissingKey);
    await _storage.delete(key: _emailVerifiedKey);
  }
}
