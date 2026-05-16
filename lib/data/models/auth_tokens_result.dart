import '../../../domain/entities/auth_session.dart';

/// Login/register API envelope (JWT + lightweight user projection).
class AuthTokensResult {
  const AuthTokensResult({
    required this.accessToken,
    required this.refreshToken,
    required this.session,
  });

  final String accessToken;
  final String refreshToken;
  final AuthenticatedSession session;
}
