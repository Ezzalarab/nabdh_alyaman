import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nabdh_alyaman/presentation/cubit/global_cubit/global_cubit.dart';
import 'package:page_transition/page_transition.dart';

import '../../core/check_active.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/widgets/common/dialog_lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String routeName = "splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    BlocProvider.of<GlobalCubit>(context, listen: false).getGlobalData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Hive.box(dataBoxName).put('introduction', true);
    CheckActive.checkActiveUser();

    return AnimatedSplashScreen(
        duration: 1000,
        splash: const MyLottie(lottie: AppStrings.lottieOnHomePage),
        splashIconSize: 250,
        backgroundColor: ColorManager.white,
        pageTransitionType: PageTransitionType.rightToLeftWithFade,
        nextScreen: const HomePage());
  }
}
