import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../pages/setting_page.dart';
import '../../resources/style.dart';
import '../forms/my_text_form_field.dart';

class AddressMainData extends StatelessWidget {
  const AddressMainData({super.key, required this.formState});
  final GlobalKey<FormState> formState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box(dataBoxName).listenable(),
        builder: (context, box, widget) {
          return Column(
            children: [
              SizedBox(
                // height: stepContentHeight,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      // margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: CSCPicker(
                        layout: Layout.vertical,
                        showStates: true,
                        showCities: true,
                        flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                        dropdownDecoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.red[100],
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        dropDownPadding: const EdgeInsets.all(12),
                        // dropDownMargin: const EdgeInsets.symmetric(vertical: 4),
                        spaceBetween: 15.0,
                        disabledDropdownDecoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
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
                        currentState: (box.get("state_name") == null)
                            ? null
                            : box.get("state_name"),
                        currentCity: (box.get("district") == null)
                            ? null
                            : box.get("district"),
                        onStateChanged: (value) {
                          // stateName = value;
                          box.put("state_name", value);
                        },
                        onCityChanged: (value) {
                          // district = value;
                          box.put("district", value);
                        },
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      // margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: formState,
                        child: MyTextFormField(
                          initialValue: ((box.get("neighborhood") == null)
                              ? null
                              : box.get("neighborhood")),
                          hint: "المنطقة",
                          hintStyle: eHintStyle,
                          blurrBorderColor: eFieldBlurrBorderColor,
                          focusBorderColor: eFieldFocusBorderColor,
                          fillColor: eFieldFillColor,
                          suffixIcon: false,
                          icon: const Icon(Icons.my_location_outlined),
                          onSave: (value) {
                            // neighborhood = value;
                            box.put("neighborhood", value);
                          },
                          validator: (value) {
                            if (value!.length < 2) {
                              return "يرجى كتابة قريتك أو حارتك";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
            ],
          );
        });
  }
}
