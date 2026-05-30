import '../../core/error/failures.dart';
import '../../data/models/auth_tokens_result.dart';
import '../../domain/entities/auth_session.dart';

AuthenticatedSession sessionFromAuthUserMap(
  Map<String, dynamic>? userMap, {
  String? fallbackRole,
}) {
  final userRole = userMap?['role'] as String?;
  final userIdDyn = userMap?['id'];
  final phone = userMap?['phone'] as String?;
  final emailRaw = userMap?['email'];
  final email = emailRaw == null ? null : emailRaw.toString();
  final emailMissing = userMap?['emailMissing'] as bool? ?? false;
  final emailVerified = userMap?['emailVerified'] as bool? ?? false;
  final mappedRole = fallbackRole ?? userRole;
  final userId = userIdDyn == null ? '' : userIdDyn.toString();
  if (mappedRole == null || mappedRole.isEmpty || userId.isEmpty) {
    throw WrongDataFailure();
  }
  return AuthenticatedSession(
    userId: userId,
    role: mappedRole,
    phone: phone,
    email: (email == null || email.isEmpty) ? null : email,
    emailMissing: emailMissing,
    emailVerified: emailVerified,
  );
}

AuthTokensResult parseAuthTokensResult(Map<String, dynamic> data) {
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
  final userJson =
      userMap is Map ? Map<String, dynamic>.from(userMap) : null;
  return AuthTokensResult(
    accessToken: accessToken,
    refreshToken: refreshToken,
    session: sessionFromAuthUserMap(userJson, fallbackRole: role),
  );
}
