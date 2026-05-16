import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/blood_types.dart';
import '../../blocs/search/search_bloc.dart';
import '../../resources/style.dart';
import '../forms/my_dropdown_button_form_field.dart';
import '../locations/state_district_picker.dart';

class SearchOptions extends StatefulWidget {
  const SearchOptions({super.key});

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _bloodType;
  int? _stateId;
  int? _districtId;

  void _maybeSearch() {
    if (_bloodType == null || _stateId == null || _districtId == null) return;
    context.read<SearchBloc>().add(
          SearchRequested(
            bloodType: _bloodType,
            stateId: _stateId,
            districtId: _districtId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: StateDistrictPicker(
                initialStateId: _stateId,
                initialDistrictId: _districtId,
                onStateChanged: (id) {
                  setState(() => _stateId = id);
                  context.read<SearchBloc>().add(
                        SearchFiltersChanged(stateId: id, districtId: null),
                      );
                },
                onDistrictChanged: (id) {
                  setState(() => _districtId = id);
                  context.read<SearchBloc>().add(
                        SearchFiltersChanged(districtId: id),
                      );
                  _maybeSearch();
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: MyDropdownButtonFormField(
                hint: "فصيلة دم المحتاج",
                value: _bloodType,
                items: BloodTypes.bloodTypes,
                blurrBorderColor: eFieldBlurrBorderColor,
                focusBorderColor: eFieldFocusBorderColor,
                fillColor: eSearchFieldFillColor,
                icon: const Icon(Icons.bloodtype_outlined),
                onChange: (value) {
                  setState(() => _bloodType = value);
                  context.read<SearchBloc>().add(
                        SearchFiltersChanged(bloodType: value),
                      );
                  _maybeSearch();
                },
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
