import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/constatns.dart';
import '../../presentation/resources/font_manager.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/widgets/common/dialog_lottie.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../domain/entities/page_view_model_data.dart';
import '../widgets/onboarding/page_view_model.dart';
import 'home_page.dart';
import 'setting_page.dart';

class IntroductionPage extends StatelessWidget {
  static const String routeName = "onboarding_page";
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(dataBoxName);
    return Scaffold(
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
        child: IntroductionScreen(
          globalBackgroundColor: ColorManager.white,
          pages: [
            myPageViewModel(
              PageViewModelData(
                  lottei: AppStrings.OnboradingPageLottie1,
                  // image: 'assets/images/4.jpg',
                  title: '',
                  description: 'ومن أحياها فكأنما أحيا الناس جميعاً'),
            ),
            myPageViewModel(
              PageViewModelData(
                  lottei: AppStrings.OnboradingPageLottie2,
                  // image: 'assets/images/4.jpg',
                  title: '',
                  description: 'نقطة دم تساوي حياة'),
            ),
            myPageViewModel(
              PageViewModelData(
                  lottei: AppStrings.OnboradingPageLottie3,
                  // image: 'assets/images/4.jpg',
                  title: '',
                  description: 'كن سبب في حياة انسان '),
            ),
          ],
          onDone: () {
            box.put('introduction', false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const HomePage();
                },
              ),
            );
          },
          onChange: (value) {},
          onSkip: () {
            // You can also override onSkip callback
            print(box.get('introduction'));
            box.put('introduction', false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const HomePage();
                },
              ),
            );
          },
          showSkipButton: true,
          // showBackButton: true,
          next: const Icon(
            Icons.arrow_forward_rounded,
            color: ColorManager.secondary,
            size: 32,
          ),
          skip: const Text(
            "تخطي",
            style: TextStyle(
                fontSize: 22,
                fontFamily: FontConstants.fontFamily,
                color: ColorManager.primary),
          ),
          done: const Text("انهاء",
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: FontConstants.fontFamily,
                  color: ColorManager.primary)),
          dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(30.0, 10.0),
              activeColor: ColorManager.primary,
              color: Colors.black26,
              spacing: const EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0))),
        ),
      ),
    );
  }
}
