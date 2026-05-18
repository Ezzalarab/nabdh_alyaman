import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../core/auth/auth_identifier.dart';
import '../../core/extensions/extension.dart';
import '../../core/utils.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../resources/constatns.dart';
import '../resources/font_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_text_form_field.dart';
import 'home_page.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  static const String routeName = '/sign-in';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<FormState> _idFormState = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = true;
  String? _pendingForgotPhone;

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? identifierValidator(String? value) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) return AppStrings.signInEmailValidatorError;
    final isPhone = str.isValidPhone ||
        str.isValidPhoneWithKeyCode ||
        str.startsWith('+967');
    if (EmailValidator.validate(str) || isPhone) return null;
    return AppStrings.signInEmailValidatorError;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.length < minCharsOfPassword) {
      return AppStrings.firebasePasswordValidatorError;
    }
    return null;
  }

  void _togglePassword() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void _leaveSignIn(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  void _submitLogin() {
    FocusScope.of(context).unfocus();
    if ((_idFormState.currentState?.validate() ?? false) &&
        (_formState.currentState?.validate() ?? false)) {
      context.read<AuthBloc>().add(
            AuthLoginSubmitted(
              identifier: identifierController.text.trim(),
              password: passwordController.text,
            ),
          );
    }
  }

  void _promptForgotPhone() {
    final key = GlobalKey<FormState>();
    final ctrl = TextEditingController();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      btnOkText: 'متابعة',
      btnCancelText: 'إلغاء',
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل رقم هاتفك اليمني',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                controller: ctrl,
                hint: 'مثال: 771234567',
                keyBoardType: TextInputType.phone,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                validator: (v) {
                  final n = normalizeAuthIdentifier(v ?? '');
                  if (n == null || n.contains('@')) {
                    return 'رقم هاتف يمني غير صالح';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      btnOkOnPress: () async {
        if (key.currentState?.validate() != true) return;
        final phone = normalizeAuthIdentifier(ctrl.text);
        if (phone == null) return;
        _pendingForgotPhone = phone;
        if (!context.mounted) return;
        context.read<AuthBloc>().add(AuthForgotPasswordSubmitted(phone));
      },
      btnCancelOnPress: () {},
    ).show();
  }

  void _promptOtp() {
    if (_pendingForgotPhone == null) return;
    final key = GlobalKey<FormState>();
    String? code;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      btnOkText: 'تأكيد',
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل رمز التحقق الذي وصل لهاتفك (إن وُجد)',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                onChange: (v) => code = v,
                hint: 'رمز من 6 أرقام',
                keyBoardType: TextInputType.number,
                autofocus: true,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                validator: (v) =>
                    (v != null && v.length >= 6) ? null : 'رمز غير صالح',
              ),
            ],
          ),
        ),
      ),
      btnOkOnPress: () {
        if (key.currentState?.validate() != true || code == null) return;
        context.read<AuthBloc>().add(
              AuthOtpVerified(
                phone: _pendingForgotPhone!,
                code: code!,
              ),
            );
      },
    ).show();
  }

  void _promptNewPassword(String resetToken) {
    final key = GlobalKey<FormState>();
    final pass1 = TextEditingController();
    final pass2 = TextEditingController();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      dismissOnTouchOutside: false,
      btnOkText: 'حفظ',
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر كلمة مرور جديدة',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                controller: pass1,
                hint: 'كلمة المرور',
                isPassword: true,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                validator: passwordValidator,
              ),
              const SizedBox(height: 8),
              MyTextFormField(
                controller: pass2,
                hint: 'تأكيد كلمة المرور',
                isPassword: true,
                blurrBorderColor: ColorManager.lightGrey,
                focusBorderColor: ColorManager.lightSecondary,
                fillColor: ColorManager.white,
                validator: (v) =>
                    v == pass1.text ? null : 'غير متطابقة',
              ),
            ],
          ),
        ),
      ),
      btnOkOnPress: () {
        if (key.currentState?.validate() != true) return;
        context.read<AuthBloc>().add(
              AuthPasswordResetSubmitted(
                resetToken: resetToken,
                newPassword: pass1.text,
              ),
            );
      },
    ).show();
  }

  void _moveToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        title: const Text(AppStrings.signInAppBarTitle),
        elevation: AppSize.s0,
        backgroundColor: ColorManager.primaryBg,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.primaryBg,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _leaveSignIn(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Utils.showSuccessSnackBar(
                context: context,
                msg: AppStrings.signInSuccessMessage,
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const HomePage()),
                (_) => false,
              );
            } else if (state is AuthFailure) {
              if (state.needsForgotPasswordRedirect) {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  title: 'تعيين كلمة مرور محلية',
                  desc: state.message,
                  btnOkText: 'نسيت كلمة المرور',
                  btnCancelOnPress: () {},
                  btnOkOnPress: _promptForgotPhone,
                ).show();
              } else {
                Utils.showSnackBar(
                  context: context,
                  msg: state.message,
                  color: ColorManager.error,
                );
              }
            } else if (state is AuthForgotSmsSentNotice) {
              Utils.showSnackBar(
                context: context,
                msg: 'تم قبول الطلب.',
                color: ColorManager.secondary,
              );
              _promptOtp();
            } else if (state is AuthReadyToChooseNewPassword) {
              _promptNewPassword(state.resetToken);
            } else if (state is AuthPasswordResetFinishedNotice) {
              Utils.showSuccessSnackBar(
                context: context,
                msg: 'تم تعيين كلمة المرور. يمكنك تسجيل الدخول.',
              );
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: state is AuthLoading,
              progressIndicator: const LoadingWidget(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSize.s30),
                    _buildHeaderImage(),
                    const SizedBox(height: AppSize.s20),
                    Form(
                      key: _formState,
                      child: Column(
                        children: [
                          _buildIdentifierField(),
                          const SizedBox(height: AppSize.s20),
                          _buildPasswordField(),
                          _buildForgotPasswordRow(),
                          const SizedBox(height: AppSize.s30),
                          MyButton(
                            title: AppStrings.signInSubmitButton,
                            color: Theme.of(context).primaryColor,
                            titleStyle:
                                Theme.of(context).textTheme.titleLarge,
                            onPressed: _submitLogin,
                            minWidth: AppSize.s300,
                          ),
                          const SizedBox(height: AppSize.s16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: ColorManager.grey2.withValues(alpha: 0.5),
                                ),
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: AppMargin.m20),
                                child: Text('أو'),
                              ),
                              Expanded(
                                child: Divider(
                                  color: ColorManager.grey2.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          MyButton(
                            title: AppStrings.signInSignUpButton,
                            color: ColorManager.white,
                            onPressed: _moveToSignUp,
                            minWidth: AppSize.s300,
                            titleStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: FontSize.s14,
                              fontFamily: FontConstants.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _leaveSignIn(context),
                            child: const Text('متابعة بدون تسجيل'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Padding _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p10),
      child: Stack(
        children: [
          SizedBox(
            height: signInImageHight,
            child: const CircleAvatar(
              backgroundImage: AssetImage(ImageAssets.signInImage),
              radius: signInImageRadius,
            ),
          ),
          const Positioned(
            bottom: AppSize.s8,
            right: AppSize.s0,
            child: Icon(Icons.add, size: AppSize.s70, color: ColorManager.white),
          ),
        ],
      ),
    );
  }

  Container _buildIdentifierField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppMargin.m40),
      child: Form(
        key: _idFormState,
        child: MyTextFormField(
          hint: AppStrings.signInEmailHint,
          controller: identifierController,
          blurrBorderColor: ColorManager.lightGrey,
          focusBorderColor: ColorManager.secondary,
          fillColor: ColorManager.white,
          validator: identifierValidator,
          keyBoardType: TextInputType.emailAddress,
          icon: const Icon(Icons.phone_android, color: ColorManager.primary),
        ),
      ),
    );
  }

  Container _buildPasswordField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: MyTextFormField(
        hint: AppStrings.signInPasswordHint,
        controller: passwordController,
        isPassword: isPasswordVisible,
        blurrBorderColor: ColorManager.lightGrey,
        focusBorderColor: ColorManager.secondary,
        fillColor: ColorManager.white,
        validator: passwordValidator,
        icon: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          color: ColorManager.primary,
          onPressed: _togglePassword,
        ),
      ),
    );
  }

  Container _buildForgotPasswordRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p50,
        vertical: AppPadding.p10,
      ),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _promptForgotPhone,
        child: Text(
          AppStrings.signInForgetPasswordTextButton,
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: ColorManager.link),
        ),
      ),
    );
  }
}
