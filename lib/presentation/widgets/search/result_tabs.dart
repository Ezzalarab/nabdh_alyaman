import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/blood_types.dart';
import '../../../domain/entities/donor.dart';
import '../../../presentation/resources/color_manageer.dart';
import '../../blocs/search/search_bloc.dart';

class ResultTabs extends StatelessWidget {
  const ResultTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchSuccess) {
          final compatibleTypes =
              BloodTypes.canReceiveFrom(bloodType: state.bloodType);
          return Container(
            width: double.infinity,
            height: 75,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: compatibleTypes.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                final List<Donor> compatibleDonors = state.donors
                    .where((donor) => donor.bloodType == compatibleTypes[index])
                    .toList();
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context
                            .read<SearchBloc>()
                            .add(SearchTabChanged(index));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(5),
                        width: state.selectedTabIndex == index ? 75 : 65,
                        height: 60,
                        decoration: BoxDecoration(
                          color: state.selectedTabIndex == index
                              ? Theme.of(context).primaryColor
                              : ColorManager.grey1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              compatibleTypes[index],
                              style: TextStyle(
                                color: state.selectedTabIndex == index
                                    ? Colors.white
                                    : ColorManager.darkGrey,
                                fontSize: 18,
                                fontWeight: state.selectedTabIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              compatibleDonors.length.toString(),
                              style: TextStyle(
                                color: state.selectedTabIndex == index
                                    ? ColorManager.white
                                    : ColorManager.darkGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: state.selectedTabIndex == index,
                      child: Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('ستظهر هنا فصائل الدم المناسبة'),
          ),
        );
      },
    );
  }
}
