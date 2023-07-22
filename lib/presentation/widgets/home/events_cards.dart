import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/event_card_data.dart';
import '../../cubit/global_cubit/global_cubit.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import 'event_card.dart';

class EventsCards extends StatelessWidget {
  const EventsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalCubit, GlobalState>(
      builder: (context, state) {
        String eventsTitle = LocalData.initialAppData.eventsTitle;
        if (state is GlobalStateSuccess) {
          eventsTitle = state.appData.eventsTitle;
        }
        List<EventCardData> eventsCardsData =
            LocalData.initialAppData.eventsCardsData;
        if (state is GlobalStateSuccess) {
          eventsCardsData = state.appData.eventsCardsData;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (eventsCardsData.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p30,
                  vertical: AppPadding.p10,
                ),
                child: Text(
                  eventsTitle,
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
              itemCount: eventsCardsData.length,
              itemBuilder: (context, index) => EventCard(
                eventData: eventsCardsData[index],
              ),
            ),
          ],
        );
      },
    );
  }
}
