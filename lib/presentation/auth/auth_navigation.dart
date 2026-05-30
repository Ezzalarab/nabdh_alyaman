import 'package:flutter/material.dart';

import '../../core/utils.dart';
import '../blocs/auth/auth_state.dart';
import '../pages/complete_email_page.dart';
import '../pages/home_page.dart';

/// Routes user after login/register/session restore.
void navigateAfterAuth(BuildContext context, AuthState state) {
  if (state is AuthNeedsEmailCompletion) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CompleteEmailPage(session: state.session),
      ),
    );
    return;
  }
  if (state is AuthAuthenticated) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
      (_) => false,
    );
  }
}

void listenForAuthNavigation(BuildContext context, AuthState state) {
  if (state is AuthNeedsEmailCompletion || state is AuthAuthenticated) {
    navigateAfterAuth(context, state);
  }
}

void listenForRegisterSuccess(BuildContext context, AuthState state) {
  if (state is AuthAuthenticated) {
    Utils.showSuccessSnackBar(
      context: context,
      msg: 'يمكنك التحقق من بريدك لاحقاً من الإعدادات',
    );
  }
  listenForAuthNavigation(context, state);
}
