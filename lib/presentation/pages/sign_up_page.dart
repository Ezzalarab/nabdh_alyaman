import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

import '../../core/utils.dart';
import '../../di.dart' as di;
import '../../domain/entities/blood_types.dart';
import '../../domain/entities/donor.dart';
import '../cubit/signup_cubit/signup_cubit.dart';
import '../resources/font_manager.dart';
import '../widgets/common/csc_picker.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../resources/constatns.dart';
import '../resources/strings_manager.dart';
import '../resources/style.dart';
import '../resources/values_manager.dart';
import '../widgets/common/my_stepper.dart' as my_stepper;
import '../widgets/forms/my_dropdown_button_form_field.dart';
import '../widgets/forms/my_text_form_field.dart';
import 'sign_in_page.dart';
import 'home_page.dart';
import 'sing_up_center_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  static const String routeName = "/sign-up";

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _firstFormState = GlobalKey<FormState>(),
      _secondFormState = GlobalKey<FormState>(),
      _thirdFormState = GlobalKey<FormState>();
  // _fourthFormState = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController(),
      nameController = TextEditingController(),
      phoneController = TextEditingController(),
      stateNameController = TextEditingController(),
      districtController = TextEditingController(),
      neighborhoodController = TextEditingController();

  String? selectedGovernorate, selectedDistrict, bloodType;
  int _activeStepIndex = 0;
  bool isPasswordHidden = true;
  bool isFirstStep() => _activeStepIndex == 0;
  bool isLastStep() => _activeStepIndex == stepList().length - 1;
  String? smsCode;

  // To Get Location Point
  final location = loc.Location();
  String lon = "", lat = "";

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    FormState? formData = _thirdFormState.currentState;
    if (formData!.validate()) {
      Donor newDonor = Donor(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        phone: phoneController.text,
        bloodType: bloodType!,
        state: stateNameController.text,
        district: districtController.text,
        neighborhood: neighborhoodController.text,
        lon: lon,
        lat: lat,
      );
      BlocProvider.of<SignUpCubit>(context).saveDonorData(
        donor: newDonor,
      );
    }
  }

  Future<void> _signUpAuth() async {
    Donor newDonor = Donor(
      email: emailController.text,
      password: passwordController.text,
      name: "",
      phone: phoneController.text,
      bloodType: "",
      state: "",
      district: "",
      neighborhood: "",
      lon: "",
      lat: "",
    );
    BlocProvider.of<SignUpCubit>(context).signUpAuthDonor(
      donor: newDonor,
      onVerificationSent: buildVerificationDialog(context),
    );
  }

  Function buildVerificationDialog(BuildContext context) {
    final GlobalKey<FormState> verificationFormState = GlobalKey<FormState>();
    return () => AwesomeDialog(
          headerAnimationLoop: false,
          dialogType: DialogType.noHeader,
          context: context,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: verificationFormState,
              child: Column(
                children: [
                  const Text(
                    "تم إرسال رسالة التأكيد إلى رقمك الذي أدخلته، قم بكتابته هنا:",
                    style: TextStyle(
                      height: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  MyTextFormField(
                    onChange: (value) => smsCode = value,
                    hint: "اكتب رقم التأكيد",
                    keyBoardType: TextInputType.number,
                    blurrBorderColor: ColorManager.lightGrey,
                    focusBorderColor: ColorManager.lightSecondary,
                    fillColor: ColorManager.white,
                    autofocus: true,
                    validator: (value) => (value != null && value.length > 5)
                        ? null
                        : "يجب كتابة رمز التأكيد المكون من 6 أرقام",
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    title: "تأكيد",
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (verificationFormState.currentState!.validate()) {
                        BlocProvider.of<SignUpCubit>(context).verify(
                          context: context,
                          smsCode: smsCode!,
                        );
                      }
                    },
                    color: ColorManager.primary,
                  ),
                ],
              ),
            ),
          ),
        ).show();
  }

  Future<void> showGpsPermissionDialog() async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      body: SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "يرجى السماح بصلاحية الوصول إلى الموقع الجغرافي ليتمكن المحتاج للدم من معرفة مكانك",
                style: TextStyle(
                  color: ColorManager.darkGrey,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    title: 'سماح',
                    color: ColorManager.success,
                    minWidth: 100,
                    onPressed: () {
                      try {
                        checkGps();
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: e.toString(),
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  MyButton(
                    title: 'رفض',
                    color: ColorManager.error,
                    minWidth: 100,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).show();
  }

  checkGps() async {
    bool haspermission = false;
    LocationPermission permission;
    if (await location.serviceEnabled()) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
        } else if (permission == LocationPermission.deniedForever) {
          if (kDebugMode) {
            print("'Location permissions are permanently denied");
          }
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
      if (haspermission) {
        await getLocation();
      }
    } else {
      if (!await location.serviceEnabled()) {
        await location.requestService();
      }
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }
  }

  getLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (kDebugMode) {
      print(currentPosition.longitude);
      print(currentPosition.latitude);
    }
    lon = currentPosition.longitude.toString();
    lat = currentPosition.latitude.toString();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    stateNameController.dispose();
    districtController.dispose();
    neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.grey0,
        title: const Text(AppStrings.signUpAppBarTitle),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.grey0,
        ),
      ),
      body: BlocConsumer<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpLoading) {
          } else {
            if (state is SignUpAuthVerifying) {
            } else if (state is SignUpDataSuccess) {
              Utils.showSuccessSnackBar(
                  context: context, msg: AppStrings.signUpSuccessMessage);
              Navigator.of(context).pushReplacementNamed(HomePage.routeName);
            } else if (state is SignUpFailure) {
              Utils.showFalureSnackBar(context: context, msg: state.error);
            } else if (state is SignUpDataFailure) {
              Utils.showFalureSnackBar(context: context, msg: state.error);
            } else if (state is SignUpAuthFailure) {
              Utils.showFalureSnackBar(context: context, msg: state.error);
            } else if (state is SignUpAuthSuccess) {
              setState(() => _activeStepIndex++);
            }
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: (state is SignUpLoading),
            progressIndicator: const LoadingWidget(),
            child: my_stepper.Stepper(
              svgPictureAsset: ImageAssets.bloodDrop,
              iconColor: Theme.of(context).primaryColor,
              elevation: AppSize.s0,
              type: my_stepper.StepperType.horizontal,
              currentStep: _activeStepIndex,
              steps: stepList(),
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              onStepTapped: _onStepTapped,
              controlsBuilder:
                  (BuildContext context, my_stepper.ControlsDetails controls) {
                return buildNavigationButtons(context, controls);
              },
            ),
          );
        },
      ),
    );
  }

  Container buildNavigationButtons(
    BuildContext context,
    my_stepper.ControlsDetails controls,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isFirstStep())
                  SizedBox(
                    width: AppSize.s140,
                    child: MyButton(
                      title: AppStrings.signUpPreviousButton,
                      // color: Theme.of(context).primaryColor,
                      titleStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: FontSize.s14,
                        fontFamily: FontConstants.fontFamily,
                      ),
                      // titleStyle: const TextStyle(
                      //   fontSize: FontSize.s14,
                      //   color: ColorManager.secondary,
                      //   fontFamily: FontConstants.fontFamily,
                      // ),
                      onPressed: controls.onStepCancel!,
                      color: ColorManager.grey1,
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: ColorManager.primary,
                          size: AppSize.s24,
                        ),
                      ),
                      isPrefexIcon: true,
                    ),
                  ),
                const SizedBox(width: AppSize.s20),
                SizedBox(
                  width: AppSize.s140,
                  child: (isLastStep())
                      ? MyButton(
                          title: AppStrings.signUpCreateButton,
                          color: ColorManager.secondary,
                          titleStyle: Theme.of(context).textTheme.titleLarge,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.check_rounded,
                              size: AppSize.s30,
                              color: ColorManager.white,
                            ),
                          ),
                          onPressed: _submit,
                        )
                      : MyButton(
                          title: AppStrings.signUpNextButton,
                          color: Theme.of(context).primaryColor,
                          titleStyle: Theme.of(context).textTheme.titleLarge,
                          onPressed: _validateForm,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: ColorManager.white,
                              size: AppSize.s24,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          isFirstStep()
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _moveToSignInPage,
                        child: Text(
                          AppStrings.signUpGoToSignIn,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: ColorManager.link,
                                  ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _moveToSignUpAsCenter,
                        child: Text(
                          AppStrings.signUpAsCenterLink,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: ColorManager.link,
                                  ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  List<my_stepper.Step> stepList() => <my_stepper.Step>[
        firstStep(),
        secondSetp(),
        thirdStep(),
        // fourthStep(),
      ];

  my_stepper.Step firstStep() {
    return my_stepper.Step(
      state: _activeStepIndex <= 0
          ? my_stepper.StepState.editing
          : my_stepper.StepState.complete,
      isActive: _activeStepIndex >= 0,
      title: Text(AppStrings.signUpFirstStepTitle,
          style: _activeStepIndex >= 0
              ? Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).primaryColor)
              : Theme.of(context).textTheme.bodySmall),
      content: SizedBox(
        height: signUpStepHight,
        child: Form(
          key: _firstFormState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.signUpFirstStepMotivationPhrase,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: ColorManager.lightSecondary),
              ),
              const SizedBox(height: AppSize.s40),
              if (BlocProvider.of<SignUpCubit>(context).canSignUpWithPhone)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppMargin.m20,
                  ),
                  child: MyTextFormField(
                    hint: AppStrings.signUpPhoneHint,
                    controller: phoneController,
                    blurrBorderColor: ColorManager.lightGrey,
                    focusBorderColor: ColorManager.lightSecondary,
                    fillColor: ColorManager.white,
                    validator: _phoneNumberValidator,
                    icon: const Icon(Icons.phone_android),
                    keyBoardType: TextInputType.number,
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppMargin.m20),
                  child: MyTextFormField(
                    hint: AppStrings.signUpEmailHint,
                    controller: emailController,
                    blurrBorderColor: ColorManager.lightGrey,
                    focusBorderColor: ColorManager.lightSecondary,
                    fillColor: ColorManager.white,
                    validator: _emailValidator,
                    icon: const Icon(Icons.email),
                    keyBoardType: TextInputType.emailAddress,
                  ),
                ),
              const SizedBox(height: signUpSpaceBetweenFields),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: MyTextFormField(
                  hint: AppStrings.signUpPasswordHint,
                  controller: passwordController,
                  isPassword: isPasswordHidden,
                  blurrBorderColor: ColorManager.lightGrey,
                  focusBorderColor: ColorManager.lightSecondary,
                  fillColor: ColorManager.white,
                  validator: _passwordValidator,
                  icon: IconButton(
                    icon: _buildPasswordIcon(),
                    onPressed: _toggleIsPasswordVisible,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  my_stepper.Step secondSetp() {
    return my_stepper.Step(
      state: _activeStepIndex <= 1
          ? my_stepper.StepState.editing
          : my_stepper.StepState.complete,
      isActive: _activeStepIndex >= 1,
      title: Text(AppStrings.signUpSecondStepTitle,
          style: _activeStepIndex >= 1
              ? Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).primaryColor)
              : Theme.of(context).textTheme.bodySmall),
      content: SizedBox(
        height: signUpStepHight,
        child: Form(
          key: _secondFormState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppMargin.m20),
                child: MyTextFormField(
                  hint: AppStrings.signUpNameHint,
                  controller: nameController,
                  blurrBorderColor: ColorManager.lightGrey,
                  focusBorderColor: ColorManager.lightSecondary,
                  fillColor: ColorManager.white,
                  validator: _nameValidator,
                  icon: const Icon(Icons.person),
                ),
              ),
              if (BlocProvider.of<SignUpCubit>(context).canSignUpWithPhone)
                const SizedBox()
              else
                const SizedBox(height: signUpSpaceBetweenFields),
              if (BlocProvider.of<SignUpCubit>(context).canSignUpWithPhone)
                const SizedBox()
              else
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppMargin.m20,
                  ),
                  child: MyTextFormField(
                    hint: AppStrings.signUpPhoneHint,
                    controller: phoneController,
                    blurrBorderColor: ColorManager.lightGrey,
                    focusBorderColor: ColorManager.lightSecondary,
                    fillColor: ColorManager.white,
                    validator: _phoneNumberValidator,
                    icon: const Icon(Icons.phone_android),
                    keyBoardType: TextInputType.number,
                  ),
                ),
              const SizedBox(height: signUpSpaceBetweenFields),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppMargin.m20),
                child: MyDropdownButtonFormField(
                  hint: AppStrings.signUpBloodTypeHint,
                  validator: _bloodTypeValidator,
                  value: bloodType,
                  hintColor: eTextColor,
                  items: BloodTypes.bloodTypes,
                  blurrBorderColor: ColorManager.lightGrey,
                  focusBorderColor: ColorManager.lightSecondary,
                  fillColor: ColorManager.white,
                  icon: const Icon(Icons.bloodtype_outlined),
                  onChange: (value) => setState(() => bloodType = value!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  my_stepper.Step thirdStep() {
    return my_stepper.Step(
      state: _activeStepIndex <= 2
          ? my_stepper.StepState.editing
          : my_stepper.StepState.complete,
      isActive: _activeStepIndex >= 2,
      title: Text(AppStrings.signUpThirdStepTitle,
          style: _activeStepIndex >= 2
              ? Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).primaryColor)
              : Theme.of(context).textTheme.bodySmall),
      content: SizedBox(
        height: signUpStepHight,
        child: Form(
          key: _thirdFormState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CSCPicker(
                  layout: Layout.vertical,
                  showStates: true,
                  showCities: true,
                  flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: ColorManager.white,
                    border: Border.all(
                      color: ColorManager.lightGrey,
                      width: 1,
                    ),
                  ),
                  dropDownPadding: const EdgeInsets.all(AppPadding.p12),
                  spaceBetween: signUpSpaceBetweenFields,
                  disabledDropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  selectedItemStyle: const TextStyle(),
                  dropdownHeadingStyle: Theme.of(context).textTheme.titleMedium,
                  dropdownItemStyle: Theme.of(context).textTheme.titleMedium,
                  dropdownDialogRadius: AppRadius.r10,
                  searchBarRadius: AppRadius.r10,
                  onStateChanged: _onStateChange,
                  onCityChanged: _onCityChanged,
                ),
              ),
              const SizedBox(height: signUpSpaceBetweenFields),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppMargin.m20),
                child: MyTextFormField(
                  hint: AppStrings.signUpNeighborhoodHint,
                  controller: neighborhoodController,
                  blurrBorderColor: ColorManager.lightGrey,
                  focusBorderColor: ColorManager.lightSecondary,
                  fillColor: ColorManager.white,
                  icon: const Icon(Icons.my_location_outlined),
                  validator: _neighborhoodValidator,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // my_stepper.Step fourthStep() {
  //   return my_stepper.Step(
  //     state: my_stepper.StepState.complete,
  //     isActive: _activeStepIndex >= 3,
  //     title: Text(AppStrings.signUpFourthStepTitle,
  //         style: _activeStepIndex >= 3
  //             ? Theme.of(context)
  //                 .textTheme
  //                 .bodySmall!
  //                 .copyWith(color: Theme.of(context).primaryColor)
  //             : Theme.of(context).textTheme.bodySmall),
  //     content: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
  //       height: signUpStepHight,
  //       child: Column(
  //         children: [
  //           Wrap(
  //             runSpacing: AppSize.s16,
  //             alignment: WrapAlignment.center,
  //             children: [
  //               buildDonorDetail(
  //                 key: AppStrings.signUpConfirmNameLabel,
  //                 value: nameController.text,
  //               ),
  //               buildDonorDetail(
  //                 key: AppStrings.signUpConfirmPhoneLabel,
  //                 value: phoneController.text,
  //               ),
  //               buildDonorDetail(
  //                 key: AppStrings.signUpConfirmBloodTypeLabel,
  //                 value: bloodType ?? AppStrings.unDefined,
  //               ),
  //               buildDonorDetail(
  //                 key: AppStrings.signUpConfirmAddressLabel,
  //                 value:
  //                     '${stateNameController.text} - ${districtController.text} - ${neighborhoodController.text}',
  //               ),
  //               buildDonorDetail(
  //                 key: AppStrings.signUpConfirmEmailLabel,
  //                 value: emailController.text,
  //               ),
  //             ],
  //           ),
  //           Form(
  //             key: _fourthFormState,
  //             child: MyCheckboxFormField(
  //               title: Row(
  //                 children: [
  //                   const Text(AppStrings.signUpIConfirmThat),
  //                   GestureDetector(
  //                     onTap: _moveToPrivacyPolicyPage,
  //                     child: Text(
  //                       AppStrings.signUpPrivacyPolicy,
  //                       style: Theme.of(context)
  //                           .textTheme
  //                           .titleMedium!
  //                           .copyWith(color: ColorManager.link),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               onSaved: (value) {},
  //               validator: _confirmValidator,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _onStepTapped(int index) {
    _validateForm(stepIndex: index);
  }

  void _validateForm({int? stepIndex}) async {
    FormState? formData = currentFormState();
    if (_activeStepIndex == 1) showGpsPermissionDialog();
    if (_activeStepIndex == 2 && districtController.text == "") {
      Fluttertoast.showToast(msg: AppStrings.signUpStateCityValidator);
    } else {
      FocusScope.of(context).unfocus();
      if (formData!.validate()) {
        formData.save();
        if (stepIndex == null) {
          if (_activeStepIndex == 0) {
            _signUpAuth();
          } else {
            setState(() => _activeStepIndex++);
          }
        } else {
          setState(() => _activeStepIndex = stepIndex);
        }
      }
    }
  }

  void _onStepCancel() {
    if (isFirstStep()) {
      return;
    }
    setState(() => _activeStepIndex -= 1);
  }

  void _onStepContinue() {
    if (_activeStepIndex < (stepList().length - 1)) {
      setState(() {
        _activeStepIndex++;
      });
    }
  }

  // String? _confirmValidator(value) =>
  //     !value! ? AppStrings.signUpYouHaveToConfirm : null;

  Icon _buildPasswordIcon() {
    return Icon(isPasswordHidden
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined);
  }

  Wrap buildDonorDetail({
    required String key,
    required String value,
  }) {
    return Wrap(
      runSpacing: 5.0,
      children: [
        Text(
          "$key:  ",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(width: 30.0),
      ],
    );
  }

  _toggleIsPasswordVisible() {
    setState(() => isPasswordHidden = !isPasswordHidden);
  }

  String? _emailValidator(value) =>
      value != null && EmailValidator.validate(value)
          ? null
          : AppStrings.signUpEmailValidator;

  String? _passwordValidator(value) => (value!.length < minCharsOfPassword)
      ? AppStrings.firebasePasswordValidatorError
      : null;

  String? _nameValidator(String? value) =>
      (value!.length < minCharsOfName) ? AppStrings.signUpNameValidator : null;

  String? _bloodTypeValidator(value) =>
      (value == null) ? AppStrings.signUpBloodTypeValidator : null;

  String? _phoneNumberValidator(String? value) {
    String pattern = r"^\+?7[0|1|3|7|8][0-9]{7}$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return AppStrings.signUpPhoneValidator;
    } else {
      return null;
    }
  }

  String? _neighborhoodValidator(value) {
    if (value!.length < 2) {
      return AppStrings.signUpNeighborhoodValidator;
    }
    return null;
  }

  void _onCityChanged(value) {
    if (value != null) {
      districtController.text = value;
    }
  }

  void _onStateChange(value) {
    if (value != null) {
      stateNameController.text = value;
    }
  }

  FormState? currentFormState() {
    if (_activeStepIndex == 0) {
      return _firstFormState.currentState;
    } else if (_activeStepIndex == 1) {
      return _secondFormState.currentState;
    } else if (_activeStepIndex == 2) {
      return _thirdFormState.currentState;
    }
    return null;
  }

  void _moveToSignUpAsCenter() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SignUpCenter(),
      ),
    );
  }

  void _moveToSignInPage() {
    di.initSignIn();
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const SignInPage())));
  }

  // void _moveToPrivacyPolicyPage() {}
}
