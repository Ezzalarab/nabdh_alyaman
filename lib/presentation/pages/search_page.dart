import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/resources/color_manageer.dart';
import '../blocs/search/search_bloc.dart';
import '../widgets/search/search_options.dart';
import '../widgets/search/search_result.dart';
import 'search_map_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  static const String routeName = 'search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن دم'),
        backgroundColor: ColorManager.primaryBg,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.primaryBg,
        ),
      ),
      backgroundColor: ColorManager.primaryBg,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: Container(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: const BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: const SearchOptions(),
            ),
          ),
          const Expanded(child: SearchResult()),
        ],
      ),
      floatingActionButton: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is! SearchSuccess) return const SizedBox();
          return FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => SearchMapPage(
                    stateDonors: state.stateDonors,
                    selectedBloodType: state.bloodType,
                  ),
                ),
              );
            },
            child: const Icon(Icons.place_outlined),
          );
        },
      ),
    );
  }
}
