// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/check_active.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../cubit/global_cubit/global_cubit.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../widgets/common/dialog_lottie.dart';
import 'home_page.dart';
import 'sign_in_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = 'splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minSplashDuration = Duration(milliseconds: 1000);

  bool _minElapsed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<GlobalCubit>(context, listen: false).getGlobalData();
    context.read<AuthBloc>().add(AuthCheckRequested());
    Future<void>.delayed(_minSplashDuration, () {
      if (!mounted) return;
      setState(() => _minElapsed = true);
      _maybeNavigate(context.read<AuthBloc>().state);
    });
  }

  void _maybeNavigate(AuthState state) {
    if (_navigated || !_minElapsed || !mounted) return;

    final Widget? next = switch (state) {
      AuthAuthenticated() => const HomePage(),
      AuthUnauthenticated() => const SignInPage(),
      _ => null,
    };
    if (next == null) return;

    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => next),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    CheckActive.checkActiveUser();
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _maybeNavigate(state),
      child: Scaffold(
        backgroundColor: ColorManager.white,
        body: Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: MyLottie(lottie: JsonAssets.bloodLoading),
          ),
        ),
      ),
    );
  }
}
