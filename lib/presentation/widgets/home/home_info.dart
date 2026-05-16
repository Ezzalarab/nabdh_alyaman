import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/global_app_data.dart';
import '../../blocs/app_config/app_config_bloc.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';

class HomeInfo extends StatelessWidget {
  const HomeInfo({super.key});

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
        final infoTitle = appData.infoTitle.isNotEmpty
            ? appData.infoTitle
            : LocalData.initialAppData.infoTitle;
        final homeInfoList = appData.infoList.isNotEmpty
            ? appData.infoList
            : LocalData.initialAppData.infoList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (homeInfoList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p30,
                  vertical: AppPadding.p10,
                ),
                child: Text(
                  infoTitle,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        height: 1.5,
                        fontSize: 20,
                        color: ColorManager.primary,
                      ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeInfoList.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '-  ${homeInfoList[index]}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(height: 1.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
