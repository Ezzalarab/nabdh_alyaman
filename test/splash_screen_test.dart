import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/domain/entities/auth_session.dart';
import 'package:nabdh_alyaman/presentation/blocs/auth/auth_state.dart';
import 'package:nabdh_alyaman/presentation/pages/home_page.dart';
import 'package:nabdh_alyaman/presentation/pages/sign_in_page.dart';
import 'package:nabdh_alyaman/presentation/pages/splash_screen.dart';

void main() {
  group('splashNavigationTarget', () {
    test('AuthUnauthenticated navigates to HomePage', () {
      final target = splashNavigationTarget(AuthUnauthenticated());
      expect(target, isA<HomePage>());
    });

    test('AuthAuthenticated navigates to HomePage', () {
      final target = splashNavigationTarget(
        AuthAuthenticated(
          const AuthenticatedSession(userId: '1', role: 'DONOR'),
        ),
      );
      expect(target, isA<HomePage>());
    });

    test('AuthNeedsEmailCompletion navigates to CompleteEmailPage', () {
      final target = splashNavigationTarget(
        AuthNeedsEmailCompletion(
          const AuthenticatedSession(
            userId: '1',
            role: 'DONOR',
            emailMissing: true,
          ),
        ),
      );
      expect(target.runtimeType.toString(), contains('CompleteEmailPage'));
    });

    test('AuthLoading returns null', () {
      expect(splashNavigationTarget(AuthLoading()), isNull);
    });

    test('does not navigate to SignInPage for guests', () {
      final target = splashNavigationTarget(AuthUnauthenticated());
      expect(target, isNot(isA<SignInPage>()));
    });
  });
}
