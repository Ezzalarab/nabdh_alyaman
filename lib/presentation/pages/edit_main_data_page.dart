// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils.dart';
import '../../domain/entities/blood_types.dart';
import '../../presentation/blocs/profile/profile_bloc.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/resources/values_manager.dart';
import '../../presentation/widgets/setting/profile_body.dart';
import '../resources/style.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_dropdown_button_form_field.dart';
import '../widgets/forms/my_text_form_field.dart';
import '../widgets/locations/state_district_picker.dart';

ProfileLocalData? profileLocalData;

class EditMainDataPage extends StatefulWidget {
  const EditMainDataPage({
    super.key,
  });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileBloc>().add(ProfileLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.profileEditMainDataPageTitle),
        ),
        backgroundColor: ColorManager.white,
        body: BlocConsumer<ProfileBloc, ProfileState>(
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
              final donor = state.donors;
              profileLocalData = ProfileLocalData(
                name: donor.name,
                bloodType: donor.bloodType,
                stateId: ProfileLocalData.parseId(donor.state),
                districtId: ProfileLocalData.parseId(donor.district),
                locationId: ProfileLocalData.parseId(donor.neighborhood),
                neighborhood: ProfileLocalData.parseId(donor.neighborhood) == null
                    ? donor.neighborhood
                    : null,
              );
              bloodType = profileLocalData!.bloodType;
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
                        initialValue: profileLocalData!.name,
                        validator: (value) {
                          if (value!.length < 2) {
                            return AppStrings.editMainDataTextNameValidator;
                          }
                          return null;
                        },
                        onSave: ((newValue) {
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
                      value: profileLocalData!.bloodType ?? bloodType,
                      items: BloodTypes.bloodTypes,
                      blurrBorderColor: ColorManager.lightGrey,
                      focusBorderColor: ColorManager.lightSecondary,
                      fillColor: ColorManager.white,
                      icon: const Icon(Icons.bloodtype_outlined),
                      onChange: (value) => setState(() {
                        bloodType = value;
                        profileLocalData!.bloodType = bloodType;
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
                    Form(
                      key: _formStateBloodType,
                      child: Column(
                        children: [
                          StateDistrictPicker(
                            initialStateId: profileLocalData!.stateId,
                            initialDistrictId: profileLocalData!.districtId,
                            onStateChanged: (id) {
                              profileLocalData!.stateId = id;
                            },
                            onDistrictChanged: (id) {
                              profileLocalData!.districtId = id;
                            },
                          ),
                          const SizedBox(height: AppSize.s14),
                          MyTextFormField(
                            initialValue: profileLocalData!.neighborhood,
                            hint: "المنطقة",
                            hintStyle: eHintStyle,
                            blurrBorderColor: ColorManager.lightGrey,
                            focusBorderColor: ColorManager.lightSecondary,
                            fillColor: ColorManager.white,
                            suffixIcon: false,
                            icon: const Icon(Icons.my_location_outlined),
                            onSave: (value) {
                              profileLocalData!.neighborhood = value;
                            },
                            validator: (value) {
                              if (value!.length < 2) {
                                return "يرجى كتابة قريتك أو حارتك";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s30),
                    MyButton(
                        title: AppStrings.profileButtonSave,
                        color: ColorManager.secondary,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: (() {
                          if (_formState.currentState!.validate() &&
                              _formStateBloodType.currentState!.validate()) {
                            _formState.currentState!.save();
                            _formStateBloodType.currentState!.save();
                            profileLocalData!.bloodType =
                                bloodType ?? profileLocalData!.bloodType;
                            if (profileLocalData!.stateId == null ||
                                profileLocalData!.districtId == null) {
                              Utils.showSnackBar(
                                context: context,
                                msg: 'يرجى اختيار المحافظة والمديرية',
                                color: ColorManager.error,
                              );
                              return;
                            }
                            context.read<ProfileBloc>().add(
                                  ProfileBasicDataUpdateSubmitted(
                                    profileLocalData!,
                                  ),
                                );
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
