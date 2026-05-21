import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/global_app_data.dart';
import '../../blocs/app_config/app_config_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../pages/search_page.dart';
import '../../pages/sign_up_page.dart';
import '../../resources/values_manager.dart';
import '../forms/my_button.dart';
import 'home_search_entry.dart';

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

        void openSearch() {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => const SearchPage()),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p20,
            vertical: AppPadding.p20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appName,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge!.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppSize.s30),
              Text(
                welcomeStatement,
                style: Theme.of(
                  context,
                ).textTheme.displayLarge!.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppSize.s40),
              HomeSearchEntry(onTap: openSearch),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, session) {
                  if (session is AuthAuthenticated) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: AppSize.s16),
                    child: MyButton(
                      title: 'تسجيل كمــتبـرع',
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const SignUpPage(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
