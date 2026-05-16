import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../cubit/global_cubit/global_cubit.dart';
import '../../pages/search_page.dart';
import '../../pages/sign_up_page.dart';
import '../../resources/color_manageer.dart';
import '../../resources/style.dart';
import '../../resources/values_manager.dart';
import '../forms/my_button.dart';
import '../forms/my_text_form_field.dart';

class HomeWelcome extends StatefulWidget {
  const HomeWelcome({super.key});

  @override
  State<HomeWelcome> createState() => _HomeWelcomeState();
}

class _HomeWelcomeState extends State<HomeWelcome> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<GlobalCubit, GlobalState>(
              builder: (context, state) {
                String appName = LocalData.initialAppData.appName;
                if (state is GlobalStateSuccess) {
                  appName = state.appData.appName;
                }
                return Text(
                  appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(height: 1.5),
                );
              },
            ),
            const SizedBox(height: AppSize.s30),
            BlocBuilder<GlobalCubit, GlobalState>(
              builder: (context, state) {
                String welcomeStatement = LocalData.initialAppData.homeHeader;
                if (state is GlobalStateSuccess) {
                  welcomeStatement = state.appData.homeHeader;
                  welcomeStatement = welcomeStatement.replaceAll("\\n", "\n");
                }
                return Text(
                  welcomeStatement,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(height: 1.5),
                );
              },
            ),
            const SizedBox(height: AppSize.s60),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.grey1,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                    spreadRadius: 3,
                  ),
                ],
              ),
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
            const SizedBox(height: AppSize.s10),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, session) {
                if (session is AuthAuthenticated) return const SizedBox();
                return MyButton(
                  title: 'إنشاء حساب متبرع',
                  color: Theme.of(context).primaryColor,
                  height: AppSize.s45,
                  titleStyle: Theme.of(context).textTheme.titleLarge,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpPage(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
