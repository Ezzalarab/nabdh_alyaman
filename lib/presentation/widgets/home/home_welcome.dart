import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di.dart' as di;
import '../../cubit/signup_cubit/signup_cubit.dart';
import '../../pages/search_page.dart';
import '../../pages/sign_up_page.dart';
import '../../resources/color_manageer.dart';
import '../../resources/style.dart';
import '../../resources/values_manager.dart';
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
                // AnimatedTextKit(
                //   pause: const Duration(milliseconds: 10000),
                //   isRepeatingAnimation: false,
                //   stopPauseOnTap: false,
                //   totalRepeatCount: 2,
                //   animatedTexts: [
                //     TyperAnimatedText(
                //       'ومن أحياها\n فكأنما أحيا الناس جميعاً',
                //       textStyle: Theme.of(context)
                //           .textTheme
                //           .displayLarge!
                //           .copyWith(height: 1.5),
                //     )
                //   ],
                // ),
                Text(
                  'ومن أحياها\n فكأنما أحيا الناس جميعاً',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(height: 1.5),
                ),
                const SizedBox(height: AppSize.s10),
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
                  child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: AppSize.s10,
                            color: ColorManager.grey2,
                            spreadRadius: AppSize.s0_5,
                          )
                        ]),
                    child: MyTextFormField(
                      hint: 'البحث عن متبرع',
                      icon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: false,
                      fillColor: ColorManager.white,
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
                ),
                const SizedBox(height: AppSize.s10),
                FirebaseAuth.instance.currentUser == null
                    ? MyButton(
                        title: 'إنشاء حساب متبرع',
                        color: Theme.of(context).primaryColor,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: () {
                          di.initSignUp();
                          BlocProvider.of<SignUpCubit>(context, listen: false)
                              .checkCanSignUpWithPhone();
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
