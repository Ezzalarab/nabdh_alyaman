// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils.dart';
import '../../domain/models/center_profile_form.dart';
import '../blocs/center/center_bloc.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/resources/values_manager.dart';
import '../resources/style.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_text_form_field.dart';
import '../widgets/locations/state_district_picker.dart';

ProfileCenterData? profileCenterData;

class EditMainCenterDataPage extends StatefulWidget {
  const EditMainCenterDataPage({
    super.key,
  });
  static const String routeName = "edit_main_center_data";

  @override
  State<EditMainCenterDataPage> createState() => _EditMainCenterDataPageState();
}

class _EditMainCenterDataPageState extends State<EditMainCenterDataPage> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<FormState> _formStateLocation = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CenterBloc>().add(CenterProfileLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileEditMainDataPageTitle),
      ),
      body: BlocConsumer<CenterBloc, CenterState>(
        listener: (context, state) {
          if (state is CenterFailure) {
            Utils.showSnackBar(
              context: context,
              msg: state.message,
              color: ColorManager.error,
            );
          } else if (state is CenterSuccess) {
            Utils.showSnackBar(
              context: context,
              msg: state.message ?? AppStrings.profileSuccesMess,
              color: ColorManager.success,
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is CenterLoadingBeforeFetch || state is CenterLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is CenterProfileLoaded) {
            profileCenterData =
                ProfileCenterData.fromBloodCenter(state.center);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p10,
                      vertical: AppPadding.p10,
                    ),
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
                    child: MyTextFormField(
                      blurrBorderColor: ColorManager.grey1,
                      focusBorderColor: ColorManager.grey2,
                      style: Theme.of(context).textTheme.bodyLarge,
                      fillColor: ColorManager.grey1,
                      initialValue: profileCenterData!.name,
                      validator: (value) {
                        if (value!.length < 2) {
                          return AppStrings.editMainDataTextNameValidator;
                        }
                        return null;
                      },
                      onSave: (newValue) {
                        profileCenterData!.name = newValue;
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        AppStrings.signUpPhoneHint,
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
                    validator: _phoneNumberValidator,
                    onSave: (newValue) {
                      profileCenterData!.phone = newValue;
                    },
                  ),
                  const SizedBox(height: AppSize.s14),
                  Form(
                    key: _formStateLocation,
                    child: Column(
                      children: [
                        StateDistrictPicker(
                          initialStateId: profileCenterData!.stateId,
                          initialDistrictId: profileCenterData!.districtId,
                          onStateChanged: (id) {
                            profileCenterData!.stateId = id;
                          },
                          onDistrictChanged: (id) {
                            profileCenterData!.districtId = id;
                          },
                        ),
                        const SizedBox(height: AppSize.s14),
                        MyTextFormField(
                          initialValue: profileCenterData!.neighborhood,
                          hint: "المنطقة",
                          hintStyle: eHintStyle,
                          blurrBorderColor: ColorManager.grey1,
                          focusBorderColor: ColorManager.grey2,
                          style: Theme.of(context).textTheme.bodyLarge,
                          fillColor: ColorManager.grey1,
                          suffixIcon: false,
                          icon: const Icon(Icons.my_location_outlined),
                          onSave: (value) {
                            profileCenterData!.neighborhood = value;
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
                    color: Theme.of(context).primaryColor,
                    titleStyle: Theme.of(context).textTheme.titleLarge,
                    onPressed: () {
                      if (_formState.currentState!.validate() &&
                          _formStateLocation.currentState!.validate()) {
                        _formState.currentState!.save();
                        _formStateLocation.currentState!.save();
                        if (profileCenterData!.stateId == null ||
                            profileCenterData!.districtId == null) {
                          Utils.showSnackBar(
                            context: context,
                            msg: 'يرجى اختيار المحافظة والمديرية',
                            color: ColorManager.error,
                          );
                          return;
                        }
                        context.read<CenterBloc>().add(
                              CenterProfileUpdateSubmitted(profileCenterData!),
                            );
                      }
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: LoadingWidget());
        },
      ),
    );
  }
}

String? _phoneNumberValidator(String? value) {
  const pattern = r"^\+?7[0|1|3|7|8][0-9]{7}$";
  final regex = RegExp(pattern);
  if (!regex.hasMatch(value!)) {
    return AppStrings.signUpPhoneValidator;
  }
  return null;
}
