/// Secure session storage (tokens and minimal user metadata).
abstract class SessionLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveUserMeta({required String userId, required String role});

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<String?> getUserId();

  Future<String?> getRole();

  Future<void> clearSession();
}
