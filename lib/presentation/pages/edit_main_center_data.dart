// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils.dart';
import '../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../presentation/pages/profile_center.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/resources/values_manager.dart';
import '../../presentation/widgets/common/dialog_lottie.dart';
import '../resources/style.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_text_form_field.dart';

ProfileCenterData? profileCenterData;

class EditMainCenterDataPage extends StatefulWidget {
  const EditMainCenterDataPage({
    Key? key,
  }) : super(key: key);
  static const String routeName = "edit_main_center_data";

  @override
  State<EditMainCenterDataPage> createState() => _EditMainCenterDataPageState();
}

class _EditMainCenterDataPageState extends State<EditMainCenterDataPage> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<FormState> _formStateBloodType = GlobalKey<FormState>();
  String? bloodType;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.profileEditMainDataPageTitle),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ProfileLoadingBeforFetch) {
              return const MyLottie(
                lottie: AppStrings.lottieOnHomePage,
              );
            }

            if (state is ProfileGetCenterData) {
              profileCenterData = ProfileCenterData(
                  name: state.bloodCenter.name,
                  phone: state.bloodCenter.phone,
                  state: state.bloodCenter.state,
                  district: state.bloodCenter.district,
                  neighborhood: state.bloodCenter.neighborhood);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      child: Text(
                        AppStrings.editMainDataTextName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: ColorManager.black),
                      ),
                    ),
                    Form(
                      key: _formState,
                      child: Column(
                        children: [
                          MyTextFormField(
                            blurrBorderColor: ColorManager.grey1,
                            focusBorderColor: ColorManager.grey2,
                            style: Theme.of(context).textTheme.bodyLarge,
                            fillColor: ColorManager.grey1,
                            initialValue: (profileCenterData!.name == null)
                                ? null
                                : profileCenterData!.name,
                            // (box.get("name") == null) ? null : box.get("name"),
                            validator: (value) {
                              if (value!.length < 2) {
                                return AppStrings.editMainDataTextNameValidator;
                              }
                              return null;
                            },
                            onSave: ((newValue) {
                              // box.put("name", newValue);
                              profileCenterData!.name = newValue;
                            }),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                "الرقم",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: ColorManager.black),
                              ),
                            ),
                          ),
                          MyTextFormField(
                            blurrBorderColor: ColorManager.grey1,
                            focusBorderColor: ColorManager.grey2,
                            style: Theme.of(context).textTheme.bodyLarge,
                            fillColor: ColorManager.grey1,
                            initialValue: profileCenterData!.phone,
                            // (box.get("name") == null) ? null : box.get("name"),
                            validator: _phoneNumberValidator,
                            onSave: ((newValue) {
                              // box.put("name", newValue);
                              profileCenterData!.phone = newValue;
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s14),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
                      child: Text(
                        AppStrings.profileAdressTitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: ColorManager.black),
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
                                  showStates: true,
                                  showCities: true,
                                  flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(AppSize.s10)),
                                    color: ColorManager.grey1,
                                    border: Border.all(
                                      color: ColorManager.white,
                                      width: 1,
                                    ),
                                  ),
                                  dropDownPadding:
                                      const EdgeInsets.all(AppPadding.p12),
                                  // dropDownMargin: const EdgeInsets.symmetric(vertical: 4),
                                  spaceBetween: AppSize.s14,
                                  disabledDropdownDecoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(AppSize.s10)),
                                    color: Colors.grey.shade300,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
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

                                  selectedItemStyle: const TextStyle(),
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
                                      (profileCenterData!.state == null)
                                          ? null
                                          : profileCenterData!.state!,
                                  currentCity:
                                      (profileCenterData!.district == null)
                                          ? null
                                          : profileCenterData!.district,
                                  onStateChanged: (value) {
                                    // stateName = value;
                                    print(profileCenterData!.state);
                                    // box.put("state_name", value);
                                    profileCenterData!.state = value;
                                  },
                                  onCityChanged: (value) {
                                    // district = value;
                                    // box.put("district", value);
                                    profileCenterData!.district = value;
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
                                        ((profileCenterData!.neighborhood ==
                                                null)
                                            ? null
                                            : profileCenterData!.neighborhood),
                                    hint: "المنطقة",
                                    hintStyle: eHintStyle,
                                    blurrBorderColor: ColorManager.grey1,
                                    focusBorderColor: ColorManager.grey2,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    fillColor: ColorManager.grey1,
                                    suffixIcon: false,
                                    icon:
                                        const Icon(Icons.my_location_outlined),
                                    onSave: (value) {
                                      // neighborhood = value;
                                      // box.put("neighborhood", value);
                                      profileCenterData!.neighborhood = value;
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
                        color: Theme.of(context).primaryColor,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: (() {
                          if (_formState.currentState!.validate()) {
                            _formState.currentState!.save();
                            if (profileCenterData != null) {
                              BlocProvider.of<ProfileCubit>(context)
                                  .sendBasicCenterDataProfile(
                                      profileCenterData!);
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
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

String? _phoneNumberValidator(String? value) {
  String pattern = r"^\+?7[0|1|3|7|8][0-9]{7}$";
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value!)) {
    return AppStrings.signUpPhoneValidator;
  } else {
    return null;
  }
}
