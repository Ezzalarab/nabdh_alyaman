import 'package:equatable/equatable.dart';

/// Authenticated REST session snapshot (minimal fields for Phase 1).
class AuthenticatedSession extends Equatable {
  const AuthenticatedSession({
    required this.userId,
    required this.role,
    this.phone,
  });

  final String userId;
  /// `DONOR` or `CENTER` from API `role`.
  final String role;
  final String? phone;

  @override
  List<Object?> get props => [userId, role, phone];
}
