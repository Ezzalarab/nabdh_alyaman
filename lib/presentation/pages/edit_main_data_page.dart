// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils.dart';
import '../../domain/entities/blood_types.dart';
import '../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/resources/values_manager.dart';
import '../../presentation/widgets/setting/profile_body.dart';
import '../resources/style.dart';
import '../widgets/common/csc_picker.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_dropdown_button_form_field.dart';
import '../widgets/forms/my_text_form_field.dart';

ProfileLocalData? profileLocalData;

class EditMainDataPage extends StatefulWidget {
  const EditMainDataPage({
    Key? key,
  }) : super(key: key);
  static const String routeName = "edit_main_data";

  @override
  State<EditMainDataPage> createState() => _EditMainDataPageState();
}

class _EditMainDataPageState extends State<EditMainDataPage> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<FormState> _formStateBloodType = GlobalKey<FormState>();
  String? bloodType;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.profileEditMainDataPageTitle),
        ),
        backgroundColor: ColorManager.white,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ProfileLoadingBeforFetch) {
              return const Center(
                child: LoadingWidget(),
              );
            }
            if (state is ProfileLoading) {
              return const Center(
                child: LoadingWidget(),
              );
            }
            if (state is ProfileGetData) {
              profileLocalData = ProfileLocalData(
                  name: state.donors.name,
                  bloodType: state.donors.bloodType,
                  state: state.donors.state,
                  district: state.donors.district,
                  neighborhood: state.donors.neighborhood);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      child: Text(
                        AppStrings.editMainDataTextName,
                        style: TextStyle(color: ColorManager.black),
                      ),
                    ),
                    Form(
                      key: _formState,
                      child: MyTextFormField(
                        blurrBorderColor: ColorManager.lightGrey,
                        focusBorderColor: ColorManager.lightSecondary,
                        fillColor: ColorManager.white,
                        initialValue: (profileLocalData!.name == null)
                            ? null
                            : profileLocalData!.name,

                        // (box.get("name") == null) ? null : box.get("name"),
                        validator: (value) {
                          if (value!.length < 2) {
                            return AppStrings.editMainDataTextNameValidator;
                          }
                          return null;
                        },
                        onSave: ((newValue) {
                          // box.put("name", newValue);
                          profileLocalData!.name = newValue;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSize.s14),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      child: Text(
                        AppStrings.profileBloodTypeTitle,
                        style: TextStyle(color: ColorManager.black),
                      ),
                    ),
                    MyDropdownButtonFormField(
                      hint: AppStrings.profileBloodTypeHint,
                      style: Theme.of(context).textTheme.bodyLarge,
                      validator: (value) {
                        return (value == null)
                            ? AppStrings.profileValidatorCheckBloodType
                            : null;
                      },
                      value: (profileLocalData!.bloodType == null)
                          ? bloodType
                          : profileLocalData!.bloodType,
                      items: BloodTypes.bloodTypes,
                      blurrBorderColor: ColorManager.lightGrey,
                      focusBorderColor: ColorManager.lightSecondary,
                      fillColor: ColorManager.white,
                      icon: const Icon(Icons.bloodtype_outlined),
                      onChange: (value) => setState(() {
                        bloodType = value;
                        setState(() {
                          profileLocalData!.bloodType = bloodType;
                        });
                      }),
                    ),
                    const SizedBox(height: AppSize.s14),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      child: Text(
                        AppStrings.profileAdressTitle,
                        style: TextStyle(color: ColorManager.black),
                      ),
                    ),
                    Column(
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
                                  bgColor: ColorManager.primaryBg,
                                  showStates: true,
                                  showCities: true,
                                  flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: ColorManager.white,
                                    border: Border.all(
                                      color: ColorManager.lightGrey,
                                      width: 1,
                                    ),
                                  ),
                                  dropDownPadding:
                                      const EdgeInsets.all(AppPadding.p12),
                                  spaceBetween: AppSize.s14,
                                  disabledDropdownDecoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: ColorManager.grey1,
                                    border: Border.all(
                                      color: ColorManager.grey1,
                                      width: 1,
                                    ),
                                  ),
                                  countrySearchPlaceholder: "الدولة",
                                  stateSearchPlaceholder: "المحافظة",
                                  citySearchPlaceholder: "المديرية",
                                  countryDropdownLabel: "الدولة",
                                  stateDropdownLabel: "المحافظة",
                                  cityDropdownLabel: "المديرية",
                                  defaultCountry: DefaultCountry.Yemen,
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
                                  currentState:
                                      (profileLocalData!.state == null)
                                          ? null
                                          : profileLocalData!.state!,
                                  currentCity:
                                      (profileLocalData!.district == null)
                                          ? null
                                          : profileLocalData!.district,
                                  onStateChanged: (value) {
                                    profileLocalData!.state = value;
                                  },
                                  onCityChanged: (value) {
                                    profileLocalData!.district = value;
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSize.s14),
                              SizedBox(
                                // margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Form(
                                  key: _formStateBloodType,
                                  child: MyTextFormField(
                                    initialValue:
                                        ((profileLocalData!.neighborhood ==
                                                null)
                                            ? null
                                            : profileLocalData!.neighborhood),
                                    hint: "المنطقة",
                                    hintStyle: eHintStyle,
                                    blurrBorderColor: ColorManager.lightGrey,
                                    focusBorderColor:
                                        ColorManager.lightSecondary,
                                    fillColor: ColorManager.white,
                                    suffixIcon: false,
                                    icon:
                                        const Icon(Icons.my_location_outlined),
                                    onSave: (value) {
                                      // neighborhood = value;
                                      // box.put("neighborhood", value);
                                      profileLocalData!.neighborhood = value;
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
                        const SizedBox(height: AppSize.s14),
                      ],
                    ),
                    const SizedBox(height: AppSize.s30),
                    MyButton(
                        title: AppStrings.profileButtonSave,
                        color: ColorManager.secondary,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: (() {
                          if (_formState.currentState!.validate() |
                              _formStateBloodType.currentState!.validate()) {
                            _formState.currentState!.save();
                            _formStateBloodType.currentState!.save();
                            if (profileLocalData != null) {
                              profileLocalData!.bloodType = bloodType;
                              BlocProvider.of<ProfileCubit>(context)
                                  .sendBasicDataProfileSectionOne(
                                      profileLocalData!);
                            } else {
                              Utils.showSnackBar(
                                context: context,
                                msg: AppStrings.profileCheckChooseOption,
                                color: ColorManager.error,
                              );
                            }
                          }
                        }))
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('خطأ غير معروف'),
              );
            }
          },
        ));
  }
}
//   MyDropdownButtonFormField myDropdownButtonFormField(
//       ProfileLocalData profileLocalData) {
//     return MyDropdownButtonFormField(
//       hint: "فصيلة دمك",
//       validator: (value) {
//         return (value == null) ? 'يرجى اختيار فصيلة الدم' : null;
//       },
//       value: (profileLocalData.bloodType == null)
//           // (box.get("blood_type") == null)
//           ? bloodType
//           : profileLocalData.bloodType,
//       // : box.get("blood_type"),
//       hintColor: eTextColor,
//       items: BloodTypes.bloodTypes,
//       blurrBorderColor: eFieldBlurrBorderColor,
//       focusBorderColor: eFieldFocusBorderColor,
//       fillColor: eFieldFillColor,
//       icon: const Icon(Icons.bloodtype_outlined),
//       onChange: (value) => setState(() {
//         bloodType = value;
//         // box.put("blood_type", bloodType);
//         setState(() {
//           profileLocalData.bloodType = value;
//         });

//         print(";;;;;;;;;sssssssss");
//       }),
//     );
//   }
// }

// // ignore: camel_case_types
// class addressData extends StatelessWidget {
//   const addressData({
//     Key? key,
//     required this.profileLocalData,
//     required GlobalKey<FormState> formStateBloodType,
//   })  : _formStateBloodType = formStateBloodType,
//         super(key: key);

//   final ProfileLocalData? profileLocalData;
//   final GlobalKey<FormState> _formStateBloodType;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           // height: stepContentHeight,
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 // margin: const EdgeInsets.symmetric(horizontal: 20),
//                 child: CSCPicker(
//                   layout: Layout.vertical,
//                   showStates: true,
//                   showCities: true,
//                   flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
//                   dropdownDecoration: BoxDecoration(
//                     borderRadius: const BorderRadius.all(Radius.circular(10)),
//                     color: Colors.red[100],
//                     border: Border.all(
//                       color: Colors.white,
//                       width: 1,
//                     ),
//                   ),
//                   dropDownPadding: const EdgeInsets.all(12),
//                   // dropDownMargin: const EdgeInsets.symmetric(vertical: 4),
//                   spaceBetween: 15.0,
//                   disabledDropdownDecoration: BoxDecoration(
//                     borderRadius: const BorderRadius.all(Radius.circular(10)),
//                     color: Colors.grey.shade300,
//                     border: Border.all(
//                       color: Colors.grey.shade300,
//                       width: 1,
//                     ),
//                   ),
//                   countrySearchPlaceholder: "الدولة",
//                   stateSearchPlaceholder: "المحافظة",
//                   citySearchPlaceholder: "المديرية",
//                   countryDropdownLabel: "الدولة",
//                   stateDropdownLabel: "المحافظة",
//                   cityDropdownLabel: "المديرية",
//                   defaultCountry: DefaultCountry.Yemen,

//                   selectedItemStyle: const TextStyle(
//                     fontWeight: FontWeight.normal,
//                     fontSize: 16,
//                   ),
//                   dropdownHeadingStyle: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                   dropdownItemStyle: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 14,
//                   ),
//                   dropdownDialogRadius: 10.0,
//                   searchBarRadius: 10.0,
//                   currentState: (profileLocalData!.state == null)
//                       ? null
//                       : profileLocalData!.state!,
//                   currentCity: (profileLocalData!.district == null)
//                       ? null
//                       : profileLocalData!.district,
//                   onStateChanged: (value) {
//                     // stateName = value;
//                     print(profileLocalData!.state);
//                     // box.put("state_name", value);
//                     profileLocalData!.state = value;
//                   },
//                   onCityChanged: (value) {
//                     // district = value;
//                     // box.put("district", value);
//                     profileLocalData!.district = value;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 15.0),
//               SizedBox(
//                 // margin: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Form(
//                   key: _formStateBloodType,
//                   child: MyTextFormField(
//                     initialValue: ((profileLocalData!.neighborhood == null)
//                         ? null
//                         : profileLocalData!.neighborhood),
//                     hint: "المنطقة",
//                     hintStyle: eHintStyle,
//                     blurrBorderColor: eFieldBlurrBorderColor,
//                     focusBorderColor: eFieldFocusBorderColor,
//                     fillColor: eFieldFillColor,
//                     suffixIcon: false,
//                     icon: const Icon(Icons.my_location_outlined),
//                     onSave: (value) {
//                       // neighborhood = value;
//                       // box.put("neighborhood", value);
//                       profileLocalData!.neighborhood = value;
//                     },
//                     validator: (value) {
//                       if (value!.length < 2) {
//                         return "يرجى كتابة قريتك أو حارتك";
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 15.0),
//       ],
//     );
//   }
// }
