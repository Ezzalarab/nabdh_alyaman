import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/local_data.dart';
import '../../domain/entities/global_app_data.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../resources/values_manager.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  static const String routeName = 'about_page';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  GlobalAppData _data(AppConfigState state, AppConfigBloc bloc) =>
      switch (state) {
        AppConfigLoaded(:final data) => data,
        AppUpdateRequired(:final data) => data,
        AppConfigFailure(:final data) => data,
        _ => bloc.data,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.primaryBg,
        title: const Text('حول التطبيق'),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.primaryBg,
        ),
      ),
      backgroundColor: ColorManager.primaryBg,
      body: BlocBuilder<AppConfigBloc, AppConfigState>(
        builder: (context, state) {
          final bloc = context.read<AppConfigBloc>();
          final appData = _data(state, bloc);
          final appName = appData.appName.isNotEmpty
              ? appData.appName
              : LocalData.initialAppData.appName;
          final aboutRaw = appData.aboutApp.replaceAll('\\n', '\n');
          final about = aboutRaw.isEmpty
              ? LocalData.initialAppData.aboutApp
              : aboutRaw;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppPadding.p30),
                  child: Image.asset(
                    ImageAssets.appLogo,
                    fit: BoxFit.cover,
                    cacheHeight: 100,
                  ),
                ),
                const SizedBox(height: AppSize.s20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'تطبيق $appName',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      about,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s50),
              ],
            ),
          );
        },
      ),
    );
  }
}
