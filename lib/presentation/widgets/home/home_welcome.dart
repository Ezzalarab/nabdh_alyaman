import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nabdh_alyaman/presentation/cubit/signup_cubit/signup_cubit.dart';

import '../../../presentation/pages/search_page.dart';
import '../../../presentation/resources/color_manageer.dart';
import '../../../../dependency_injection.dart' as di;
import '../../pages/sign_up_page.dart';
import '../../resources/style.dart';
import '../forms/my_button.dart';
import '../forms/my_text_form_field.dart';

class HomeWelcome extends StatefulWidget {
  const HomeWelcome({Key? key}) : super(key: key);

  @override
  State<HomeWelcome> createState() => _HomeWelcomeState();
}

class _HomeWelcomeState extends State<HomeWelcome> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
        ),
        SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
        ),
        SizedBox(
          height: 350,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  // pause: const Duration(milliseconds: 1000),
                  // // isRepeatingAnimation: true,
                  // stopPauseOnTap: false,
                  totalRepeatCount: 2,
                  animatedTexts: [
                    TyperAnimatedText(
                      'ومن أحياها\n فكأنما أحيا الناس جميعاً',
                      textStyle: Theme.of(context)
                          .textTheme
                          .displayLarge!
                          .copyWith(height: 1.5),
                    )
                  ],
                  // child: Text(
                  //   'ومن أحياها\n فكأنما أحيا الناس جميعاً',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .displayLarge!
                  //       .copyWith(height: 1.5),
                  // ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                          color: ColorManager.grey.withOpacity(0.4),
                          blurRadius: 2.0,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: MyTextFormField(
                    hint: 'البحث عن متبرع',
                    icon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    suffixIcon: false,
                    fillColor: ColorManager.grey1,
                    blurrBorderColor: eSecondColor.withOpacity(0),
                    focusBorderColor: eSecondColor.withOpacity(0),
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: ColorManager.grey),
                    readOnly: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchPage(),
                        ),
                      );
                    },
                  ),
                ),
                FirebaseAuth.instance.currentUser == null
                    ? MyButton(
                        title: 'إنشاء حساب متبرع',
                        color: Theme.of(context).primaryColor,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: () {
                          BlocProvider.of<SignUpCubit>(context, listen: false)
                              .checkCanSignUpWithPhone();
                          di.initSignUp();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
