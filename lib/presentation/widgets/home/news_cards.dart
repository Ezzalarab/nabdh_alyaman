import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/news_card_data.dart';
import '../../cubit/global_cubit/global_cubit.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import 'news_card.dart';

class NewsCards extends StatelessWidget {
  const NewsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      builder: (context, state) {
        String newsTitle = LocalData.initialAppData.newsTitle;
        if (state is GlobalStateSuccess) {
          newsTitle = state.appData.newsTitle;
        }
        List<NewsCardData> newsCardsData =
            LocalData.initialAppData.newsCardsData;
        if (state is GlobalStateSuccess) {
          newsCardsData = state.appData.newsCardsData;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (newsCardsData.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p30,
                  vertical: AppPadding.p10,
                ),
                child: Text(
                  newsTitle,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        height: 1.5,
                        fontSize: 20,
                        color: ColorManager.primary,
                      ),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newsCardsData.length,
              itemBuilder: (context, index) => NewsCard(
                newsData: newsCardsData[index],
              ),
            ),
          ],
        );
      },
    );
  }
}
