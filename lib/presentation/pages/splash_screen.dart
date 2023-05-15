import '../../core/check_active.dart';
import '../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/setting_page.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/widgets/common/dialog_lottie.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String routeName = "splash_screen";

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
