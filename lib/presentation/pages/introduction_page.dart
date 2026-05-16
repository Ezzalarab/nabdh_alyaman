import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../data/datasources/local/preferences_local_datasource.dart';
import '../../di.dart' as di;
import '../../domain/entities/page_view_model_data.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/font_manager.dart';
import '../resources/assets_manager.dart';
import '../widgets/onboarding/page_view_model.dart';
import 'home_page.dart';

class IntroductionPage extends StatelessWidget {
  static const String routeName = 'onboarding_page';
  const IntroductionPage({super.key});

  Future<void> _finish(BuildContext context) async {
    await di.gi<PreferencesLocalDataSource>().setOnboardingDone(true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: ColorManager.white,
        pages: [
          myPageViewModel(
            PageViewModelData(
              lottei: JsonAssets.bloodSaveLife,
              title: '',
              description: 'ومن أحياها فكأنما أحيا الناس جميعاً',
            ),
          ),
          myPageViewModel(
            PageViewModelData(
              lottei: JsonAssets.healthHeart,
              title: '',
              description: 'قطرة دم تساوي حياة',
            ),
          ),
          myPageViewModel(
            PageViewModelData(
              lottei: JsonAssets.transfusionBag,
              title: '',
              description: 'كن سبب في حياة انسان ',
            ),
          ),
        ],
        onDone: () => _finish(context),
        onChange: (_) {},
        onSkip: () => _finish(context),
        showSkipButton: true,
        next: const Icon(
          Icons.arrow_forward_rounded,
          color: ColorManager.secondary,
          size: 32,
        ),
        skip: const Text(
          'تخطي',
          style: TextStyle(
            fontSize: 22,
            fontFamily: FontConstants.fontFamily,
            color: ColorManager.primary,
          ),
        ),
        done: const Text(
          'انهاء',
          style: TextStyle(
            fontSize: 22,
            fontFamily: FontConstants.fontFamily,
            color: ColorManager.primary,
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(30.0, 10.0),
          activeColor: ColorManager.primary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
