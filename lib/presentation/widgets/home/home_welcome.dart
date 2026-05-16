import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/global_app_data.dart';
import '../../blocs/app_config/app_config_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../pages/blood_request/create_blood_request_page.dart';
import '../../pages/search_page.dart';
import '../../pages/sign_up_page.dart';
import '../../resources/color_manageer.dart';
import '../../resources/style.dart';
import '../../resources/values_manager.dart';
import '../forms/my_button.dart';
import '../forms/my_text_form_field.dart';

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({super.key});

  GlobalAppData _data(AppConfigState state, AppConfigBloc bloc) =>
      switch (state) {
        AppConfigLoaded(:final data) => data,
        AppUpdateRequired(:final data) => data,
        AppConfigFailure(:final data) => data,
        _ => bloc.data,
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigBloc, AppConfigState>(
      builder: (context, state) {
        final bloc = context.read<AppConfigBloc>();
        final appData = _data(state, bloc);
        final appName = appData.appName.isNotEmpty
            ? appData.appName
            : LocalData.initialAppData.appName;
        final header = appData.homeHeader.replaceAll('\\n', '\n');
        final welcomeStatement = header.isEmpty
            ? LocalData.initialAppData.homeHeader
            : header;

        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(height: 1.5),
                ),
                const SizedBox(height: AppSize.s30),
                Text(
                  welcomeStatement,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(height: 1.5),
                ),
                const SizedBox(height: AppSize.s60),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.grey1,
                        blurRadius: 5,
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
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SearchPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSize.s10),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, session) {
                    if (session is AuthAuthenticated) {
                      return MyButton(
                        title: 'طلب استغاثة',
                        color: ColorManager.secondary,
                        height: AppSize.s45,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const CreateBloodRequestPage(),
                            ),
                          );
                        },
                      );
                    }
                    return MyButton(
                      title: 'إنشاء حساب متبرع',
                      color: Theme.of(context).primaryColor,
                      height: AppSize.s45,
                      titleStyle: Theme.of(context).textTheme.titleLarge,
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
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
      },
    );
  }
}
