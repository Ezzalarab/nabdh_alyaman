import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/resources/color_manageer.dart';
import '../cubit/maps_cubit/maps_cubit.dart';
import '../cubit/search_cubit/search_cubit.dart';
import '../widgets/search/search_options.dart';
import '../widgets/search/search_result.dart';
import 'search_map_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);
  static const String routeName = 'search';

  @override
  Widget build(BuildContext context) {
    // print("search refresh");
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن دم'),
        backgroundColor: ColorManager.grey0,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.grey0,
        ),
      ),
      backgroundColor: ColorManager.grey0,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 150,
            child: Container(
              margin: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              decoration: const BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SearchOptions(),
            ),
          ),
          const Expanded(
            child: SearchResult(),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return (state is SearchSuccess)
              ? FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () async {
                    BlocProvider.of<MapsCubit>(context).showMaps(
                      stateDonors: state.stateDonors,
                      selectedBloodType: BlocProvider.of<SearchCubit>(context)
                              .selectedBloodType ??
                          "AB+",
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchMapPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.place_outlined),
                )
              : const SizedBox();
        },
      ),
    );
  }
}
