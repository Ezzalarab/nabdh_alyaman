import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../cubit/global_cubit/global_cubit.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';

class HomeInfo extends StatelessWidget {
  const HomeInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      builder: (context, state) {
        String infoTitle = LocalData.initialAppData.infoTitle;
        if (state is GlobalStateSuccess) {
          infoTitle = state.appData.infoTitle;
        }
        List<String> homeInfoList = LocalData.initialAppData.infoList;
        if (state is GlobalStateSuccess) {
          homeInfoList = state.appData.infoList;
        }
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "-  ${homeInfoList[index]}",
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
