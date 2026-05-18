import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/global_app_data.dart';
import '../../blocs/app_config/app_config_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../pages/blood_request/create_blood_request_page.dart';
import '../../pages/search_page.dart';
import '../../pages/sign_in_page.dart';
import '../../pages/sign_up_page.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import '../forms/my_button.dart';

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({super.key});

  Future<void> _promptSignInForBloodRequest(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('طلب استغاثة'),
        content: const Text(
          'لإرسال طلب استغاثة يلزم تسجيل الدخول. يمكنك البحث عن متبرعين فوراً بدون حساب.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
    if (proceed == true && context.mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      );
    }
  }

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
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, session) {
                    final primaryStyle =
                        Theme.of(context).textTheme.titleLarge;

                    void openSearch() {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SearchPage(),
                        ),
                      );
                    }

                    if (session is AuthAuthenticated) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyButton(
                            title: 'البحث عن متبرع',
                            color: Theme.of(context).primaryColor,
                            height: AppSize.s50,
                            minWidth: double.infinity,
                            titleStyle: primaryStyle,
                            isPrefexIcon: true,
                            icon: const Icon(
                              Icons.search_rounded,
                              color: ColorManager.white,
                            ),
                            onPressed: openSearch,
                          ),
                          MyButton(
                            title: 'طلب استغاثة',
                            color: ColorManager.secondary,
                            height: AppSize.s45,
                            titleStyle: primaryStyle,
                            onPressed: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const CreateBloodRequestPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyButton(
                          title: 'البحث عن متبرع',
                          color: Theme.of(context).primaryColor,
                          height: AppSize.s50,
                          minWidth: double.infinity,
                          titleStyle: primaryStyle,
                          isPrefexIcon: true,
                          icon: const Icon(
                            Icons.search_rounded,
                            color: ColorManager.white,
                          ),
                          onPressed: openSearch,
                        ),
                        MyButton(
                          title: 'تسجيل كمتبرع',
                          color: ColorManager.secondary,
                          height: AppSize.s45,
                          titleStyle: primaryStyle,
                          onPressed: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const SignUpPage(),
                              ),
                            );
                          },
                        ),
                        MyButton(
                          title: 'تسجيل الدخول',
                          color: ColorManager.white,
                          height: AppSize.s45,
                          titleStyle: primaryStyle?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const SignInPage(),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () =>
                              _promptSignInForBloodRequest(context),
                          child: const Text('طلب استغاثة'),
                        ),
                      ],
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
