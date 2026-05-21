import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/resources/color_manageer.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/search/search_bloc.dart';
import '../widgets/search/search_options.dart';
import '../widgets/search/search_result.dart';
import 'blood_request/create_blood_request_page.dart';
import 'search_map_page.dart';
import 'sign_in_page.dart';

class _SearchFilters {
  const _SearchFilters({this.bloodType, this.stateId, this.districtId});

  final String? bloodType;
  final int? stateId;
  final int? districtId;

  bool get isComplete =>
      bloodType != null &&
      bloodType!.isNotEmpty &&
      stateId != null &&
      districtId != null;
}

_SearchFilters _resolveSearchFilters(SearchState state) {
  if (state is SearchInitial) {
    return _SearchFilters(
      bloodType: state.bloodType,
      stateId: state.stateId,
      districtId: state.districtId,
    );
  }
  if (state is SearchLoading) {
    return _SearchFilters(
      bloodType: state.bloodType,
      stateId: state.stateId,
      districtId: state.districtId,
    );
  }
  if (state is SearchSuccess) {
    return _SearchFilters(
      bloodType: state.bloodType,
      stateId: state.stateId,
      districtId: state.districtId,
    );
  }
  if (state is SearchFailure) {
    return _SearchFilters(
      bloodType: state.bloodType,
      stateId: state.stateId,
      districtId: state.districtId,
    );
  }
  return const _SearchFilters();
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const String routeName = 'search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _pendingMapOpen = false;

  static const _filtersRequiredMessage =
      'حدّد المحافظة والمديرية وفصيلة الدم لعرض الخريطة';

  void _openMap(SearchSuccess state) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SearchMapPage(
          stateDonors: state.stateDonors,
          selectedBloodType: state.bloodType,
          stateId: state.stateId,
        ),
      ),
    );
  }

  void _onMapPressed() {
    final bloc = context.read<SearchBloc>();
    final filters = _resolveSearchFilters(bloc.state);

    if (!filters.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_filtersRequiredMessage)),
      );
      return;
    }

    final current = bloc.state;
    if (current is SearchSuccess) {
      _openMap(current);
      return;
    }

    setState(() => _pendingMapOpen = true);
    bloc.add(
      SearchRequested(
        bloodType: filters.bloodType,
        stateId: filters.stateId,
        districtId: filters.districtId,
      ),
    );
  }

  Future<void> _onDistressPressed() async {
    final session = context.read<AuthBloc>().state;
    if (session is AuthAuthenticated) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const CreateBloodRequestPage(),
        ),
      );
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('طلب استغاثة'),
        content: const Text(
          'لإرسال طلب استغاثة يلزم تسجيل الدخول. يمكنك البحث عن متبرعين فوراً بدون حساب.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
    if (proceed == true && mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listener: (context, state) {
        if (!_pendingMapOpen) return;
        if (state is SearchSuccess) {
          setState(() => _pendingMapOpen = false);
          _openMap(state);
        } else if (state is SearchFailure) {
          setState(() => _pendingMapOpen = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('البحث عن دم'),
          backgroundColor: ColorManager.primaryBg,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorManager.primaryBg,
          ),
          actions: [
            IconButton(
              onPressed: _onDistressPressed,
              tooltip: 'طلب استغاثة',
              icon: Icon(
                Icons.emergency_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: _onMapPressed,
          tooltip: 'الخريطة',
          child: const Icon(Icons.place_outlined),
        ),
      ),
    );
  }
}
