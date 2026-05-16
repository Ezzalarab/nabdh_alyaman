import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../core/auth/auth_identifier.dart';
import '../../core/utils.dart';
import '../../data/datasources/local/locations_local_datasource.dart';
import '../../data/datasources/remote/locations_remote_datasource.dart';
import '../../data/models/cached_location_row.dart';
import '../../di.dart' as di;
import '../../domain/entities/blood_types.dart';
import '../../domain/entities/donor_registration_params.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../resources/constatns.dart';
import '../resources/strings_manager.dart';
import '../resources/style.dart';
import '../resources/values_manager.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/my_stepper.dart' as my_stepper;
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_dropdown_button_form_field.dart';
import '../widgets/forms/my_text_form_field.dart';
import 'home_page.dart';
import 'sign_in_page.dart';
import 'sing_up_center_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  static const String routeName = '/sign-up';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstForm = GlobalKey<FormState>();
  final _secondForm = GlobalKey<FormState>();
  final _thirdForm = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final neighborhoodController = TextEditingController();

  String? bloodType;
  String? genderCode;
  int _step = 0;
  bool obscurePass = true;
  late final loc.Location location;
  String lon = '', lat = '';

  List<CachedLocationState> _states = [];
  List<CachedLocationDistrict> _districts = [];
  int? _stateId;
  int? _districtId;

  static const _genders = [('MALE', 'ذكر'), ('FEMALE', 'أنثى')];

  @override
  void initState() {
    super.initState();
    location = loc.Location();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStates());
  }

  Future<void> _loadStates() async {
    try {
      final ds = di.gi<LocationsRemoteDataSource>();
      final rows = await ds.fetchStates();
      await di.gi<LocationsLocalDataSource>().replaceStates(rows);
      if (mounted) setState(() => _states = rows);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر تحميل المحافظات');
    }
  }

  Future<void> _onState(int? id) async {
    setState(() {
      _stateId = id;
      _districtId = null;
      _districts = [];
    });
    if (id == null) return;
    try {
      final list = await di.gi<LocationsRemoteDataSource>().fetchDistricts(id);
      await di.gi<LocationsLocalDataSource>().replaceDistricts(list);
      if (mounted) setState(() => _districts = list);
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر تحميل المديريات');
    }
  }

  Future<void> _gpsDialog() async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      body: SizedBox(
        width: 300,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'يُستحسن السماح بالموقع لعرض المتبرعين القريبين منك تقريبيًا.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
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
                      Fluttertoast.showToast(msg: e.toString());
                    }
                    Navigator.of(context).pop();
                  },
                ),
                MyButton(
                  title: 'رفض',
                  color: ColorManager.error,
                  minWidth: 100,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    ).show();
  }

  Future<void> checkGps() async {
    LocationPermission permission;
    if (await location.serviceEnabled()) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        await getLocation();
      }
    }
  }

  Future<void> getLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    lon = position.longitude.toString();
    lat = position.latitude.toString();
  }

  FormState? formForStep() =>
      _step == 0 ? _firstForm.currentState : _step == 1 ? _secondForm.currentState : _thirdForm.currentState;

  Future<void> advance({int? to}) async {
    if (to != null) {
      setState(() => _step = to);
      return;
    }

    final f = formForStep();
    if (f == null || !f.validate()) return;

    if (_step == 2) {
      if (_stateId == null || _districtId == null) {
        Fluttertoast.showToast(msg: AppStrings.signUpStateCityValidator);
        return;
      }
      await _finalize();
      return;
    }

    if (_step == 1) unawaited(_gpsDialog());
    setState(() => _step++);
  }

  Future<void> _finalize() async {
    final phoneNorm = normalizeAuthIdentifier(phoneController.text);
    if (phoneNorm == null || phoneNorm.contains('@')) {
      Fluttertoast.showToast(msg: 'رقم الهاتف غير صالح للتسجيل');
      return;
    }
    if (bloodType == null ||
        genderCode == null ||
        _stateId == null ||
        _districtId == null) {
      Fluttertoast.showToast(msg: AppStrings.signUpStateCityValidator);
      return;
    }
    final emailTrim = emailController.text.trim();
    context.read<AuthBloc>().add(
          AuthRegisterDonorSubmitted(
            DonorRegistrationParams(
              fullName: nameController.text.trim(),
              phone: phoneNorm,
              password: passwordController.text,
              bloodType: bloodType!,
              gender: genderCode!,
              email: emailTrim.isEmpty ? null : emailTrim,
              stateId: _stateId!,
              districtId: _districtId!,
              locationId: _districtId!,
              lat: lat.isEmpty ? null : double.tryParse(lat),
              lon: lon.isEmpty ? null : double.tryParse(lon),
            ),
          ),
        );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryBg,
        title: const Text(AppStrings.signUpAppBarTitle),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.primaryBg,
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Utils.showSuccessSnackBar(context: context, msg: AppStrings.signUpSuccessMessage);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
              (_) => false,
            );
          } else if (state is AuthFailure) {
            Utils.showFalureSnackBar(context: context, msg: state.message);
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is AuthLoading,
            progressIndicator: const LoadingWidget(),
            child: my_stepper.Stepper(
              svgPictureAsset: ImageAssets.bloodDrop,
              iconColor: Theme.of(context).primaryColor,
              elevation: AppSize.s0,
              type: my_stepper.StepperType.horizontal,
              currentStep: _step,
              steps: [_stepOne(), _stepTwo(), _stepThree()],
              onStepContinue: () {},
              onStepCancel: () {
                if (_step > 0) setState(() => _step--);
              },
              onStepTapped: (i) => advance(to: i),
              controlsBuilder: (ctx, ctrl) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_step > 0)
                              SizedBox(
                                width: 140,
                                child: MyButton(
                                  title: AppStrings.signUpPreviousButton,
                                  color: ColorManager.grey1,
                                  onPressed: () => setState(() => _step--),
                                  icon: const Icon(Icons.arrow_back_ios, color: ColorManager.primary),
                                  isPrefexIcon: true,
                                ),
                              ),
                            SizedBox(
                              width: 140,
                              child: MyButton(
                                title: _step == 2
                                    ? AppStrings.signUpCreateButton
                                    : AppStrings.signUpNextButton,
                                color:
                                    _step == 2 ? ColorManager.secondary : Theme.of(context).primaryColor,
                                titleStyle: Theme.of(context).textTheme.titleLarge,
                                onPressed: () => advance(),
                              ),
                            ),
                          ],
                        ),
                        if (_step == 0) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const SignInPage()),
                              ),
                              child: Text(AppStrings.signUpGoToSignIn,
                                  style: TextStyle(color: ColorManager.link)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const SignUpCenter()),
                              ),
                              child: Text(AppStrings.signUpAsCenterLink,
                                  style: TextStyle(color: ColorManager.link)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  my_stepper.Step _stepOne() {
    return my_stepper.Step(
      state: _step <= 0 ? my_stepper.StepState.editing : my_stepper.StepState.complete,
      isActive: _step >= 0,
      title: Text(AppStrings.signUpFirstStepTitle),
      content: SizedBox(
        height: signUpStepHight,
        child: Form(
          key: _firstForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextFormField(
                hint: AppStrings.signUpPhoneHint,
                controller: phoneController,
                validator: _phoneValidator,
                keyBoardType: TextInputType.number,
                suffixIcon: true,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                icon: const Icon(Icons.phone_android),
              ),
              const SizedBox(height: signUpSpaceBetweenFields),
              MyTextFormField(
                hint: AppStrings.signUpPasswordHint,
                controller: passwordController,
                isPassword: obscurePass,
                validator: _passValidator,
                suffixIcon: true,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                icon: IconButton(
                  icon: Icon(obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => obscurePass = !obscurePass),
                ),
              ),
              const SizedBox(height: signUpSpaceBetweenFields),
              MyTextFormField(
                hint: 'البريد (اختياري)',
                controller: emailController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return EmailValidator.validate(v.trim()) ? null : AppStrings.signUpEmailValidator;
                },
                keyBoardType: TextInputType.emailAddress,
                suffixIcon: true,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                icon: const Icon(Icons.email),
              ),
            ],
          ),
        ),
      ),
    );
  }

  my_stepper.Step _stepTwo() {
    return my_stepper.Step(
      state: _step <= 1 ? my_stepper.StepState.editing : my_stepper.StepState.complete,
      isActive: _step >= 1,
      title: Text(AppStrings.signUpSecondStepTitle),
      content: SizedBox(
        height: signUpStepHight,
        child: Form(
          key: _secondForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextFormField(
                hint: AppStrings.signUpNameHint,
                controller: nameController,
                validator: _nameValidator,
                suffixIcon: false,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                icon: const Icon(Icons.person, color: ColorManager.secondary),
              ),
              const SizedBox(height: signUpSpaceBetweenFields),
              MyDropdownButtonFormField(
                hint: AppStrings.signUpBloodTypeHint,
                validator: _bloodValidator,
                value: bloodType,
                hintColor: eTextColor,
                items: BloodTypes.bloodTypes,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                icon: const Icon(Icons.bloodtype_outlined),
                onChange: (v) => setState(() => bloodType = v),
              ),
              const SizedBox(height: signUpSpaceBetweenFields),
              DropdownButtonFormField<String>(
                value: genderCode,
                hint: const Text('الجنس'),
                validator: (v) => v == null ? 'اختر الجنس' : null,
                items: _genders.map((g) => DropdownMenuItem(value: g.$1, child: Text(g.$2))).toList(),
                onChanged: (v) => setState(() => genderCode = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  my_stepper.Step _stepThree() {
    return my_stepper.Step(
      state: _step <= 2 ? my_stepper.StepState.editing : my_stepper.StepState.complete,
      isActive: _step >= 2,
      title: Text(AppStrings.signUpThirdStepTitle),
      content: SizedBox(
        height: signUpStepHight,
        child: Form(
          key: _thirdForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<int>(
                value: _stateId,
                hint: const Text('المحافظة'),
                items: _states
                    .map((s) => DropdownMenuItem(
                          value: s.stateId,
                          child: Text(s.nameAr, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: _onState,
                validator: (v) => v == null ? AppStrings.signUpStateCityValidator : null,
              ),
              DropdownButtonFormField<int>(
                value: _districtId,
                hint: const Text('المديرية'),
                items: _districts
                    .where((d) => d.stateId == _stateId)
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.districtId,
                        child: Text(d.nameAr, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _districtId = v),
                validator: (v) => v == null ? AppStrings.signUpStateCityValidator : null,
              ),
              MyTextFormField(
                hint: AppStrings.signUpNeighborhoodHint,
                controller: neighborhoodController,
                validator: _nhValidator,
                icon: const Icon(Icons.my_location_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _phoneValidator(String? v) {
    const pattern = r'^\+?7[0|1|3|7|8][0-9]{7}$';
    return RegExp(pattern).hasMatch(v ?? '') ? null : AppStrings.signUpPhoneValidator;
  }

  String? _passValidator(String? v) =>
      (v == null || v.length < minCharsOfPassword)
          ? AppStrings.firebasePasswordValidatorError
          : null;

  String? _nameValidator(String? v) =>
      ((v ?? '').trim().length < minCharsOfName) ? AppStrings.signUpNameValidator : null;

  String? _bloodValidator(String? v) => v == null ? AppStrings.signUpBloodTypeValidator : null;

  String? _nhValidator(String? v) =>
      ((v ?? '').trim().length < 2) ? AppStrings.signUpNeighborhoodValidator : null;
}
