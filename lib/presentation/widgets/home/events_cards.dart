import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local_data.dart';
import '../../../domain/entities/event_card_data.dart';
import '../../../domain/entities/global_app_data.dart';
import '../../blocs/app_config/app_config_bloc.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import 'event_card.dart';

class EventsCards extends StatelessWidget {
  const EventsCards({super.key});

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
        final eventsTitle = appData.eventsTitle.isNotEmpty
            ? appData.eventsTitle
            : LocalData.initialAppData.eventsTitle;
        final List<EventCardData> eventsCardsData = appData.eventsCardsData;

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
