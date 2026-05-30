/// Secure session storage (tokens and minimal user metadata).
abstract class SessionLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveUserMeta({
    required String userId,
    required String role,
    String? phone,
    String? email,
    bool emailMissing = false,
    bool emailVerified = false,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<String?> getUserId();

  Future<String?> getRole();

  Future<String?> getPhone();

  Future<String?> getEmail();

  Future<bool> getEmailMissing();

  Future<bool> getEmailVerified();

  Future<void> clearSession();
}
