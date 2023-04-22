import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/search_cubit/search_cubit.dart';
import '../../../domain/entities/blood_types.dart';
import '../../resources/style.dart';
import '../forms/my_dropdown_button_form_field.dart';

class SearchOptions extends StatelessWidget {
  SearchOptions({
    Key? key,
  }) : super(key: key);

  final GlobalKey<FormState> searchFormState = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: searchFormState,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: CSCPicker(
                layout: Layout.horizontal,
                showStates: true,
                showCities: true,
                flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                dropdownDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: eFieldFillColor,
                  border: Border.all(
                    color: eFieldFocusBorderColor,
                    width: 1,
                  ),
                ),
                dropDownPadding: const EdgeInsets.all(12),
                spaceBetween: 20.0,
                disabledDropdownDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.grey.shade300,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                countrySearchPlaceholder: "الدولة",
                stateSearchPlaceholder: "المحافطة",
                citySearchPlaceholder: "المديرية",
                countryDropdownLabel: "الدولة",
                stateDropdownLabel: "المحافطة",
                cityDropdownLabel: "المديرية",
                defaultCountry: DefaultCountry.Yemen,
                selectedItemStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                dropdownHeadingStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                dropdownItemStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                dropdownDialogRadius: 10.0,
                searchBarRadius: 10.0,
                onCountryChanged: (value) {},
                onStateChanged: (value) {
                  if (value != null) {
                    BlocProvider.of<SearchCubit>(context).selectedState = value;
                  }
                },
                onCityChanged: (value) async {
                  if (value != null) {
                    BlocProvider.of<SearchCubit>(context).selectedDistrict =
                        value;
                  }
                  if (BlocProvider.of<SearchCubit>(context).selectedBloodType !=
                          null &&
                      BlocProvider.of<SearchCubit>(context).selectedDistrict !=
                          '') {
                    BlocProvider.of<SearchCubit>(context)
                        .searchDonorsAndCenters();
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: MyDropdownButtonFormField(
                hint: "فصيلة دمك",
                value: BlocProvider.of<SearchCubit>(context).selectedBloodType,
                items: BloodTypes.bloodTypes,
                blurrBorderColor: eFieldBlurrBorderColor,
                focusBorderColor: eFieldFocusBorderColor,
                fillColor: eSearchFieldFillColor,
                icon: const Icon(Icons.bloodtype_outlined),
                onChange: (value) async {
                  BlocProvider.of<SearchCubit>(context).selectedBloodType =
                      value!;
                  if (BlocProvider.of<SearchCubit>(context).selectedState !=
                          '' &&
                      BlocProvider.of<SearchCubit>(context).selectedDistrict !=
                          '') {
                    BlocProvider.of<SearchCubit>(context)
                        .searchDonorsAndCenters();
                  }
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
