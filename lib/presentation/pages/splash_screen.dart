// ignore_for_file: depend_on_referenced_packages

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import '../../core/check_active.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../cubit/global_cubit/global_cubit.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../widgets/common/dialog_lottie.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = 'splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<GlobalCubit>(context, listen: false).getGlobalData();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    CheckActive.checkActiveUser();
    return AnimatedSplashScreen(
      duration: 1000,
      splash: const MyLottie(lottie: JsonAssets.bloodLoading),
      splashIconSize: 250,
      backgroundColor: ColorManager.white,
      pageTransitionType: PageTransitionType.rightToLeftWithFade,
      nextScreen: const HomePage(),
    );
  }
}
