import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../core/auth/auth_identifier.dart';
import '../../core/extensions/extension.dart';
import '../../core/utils.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../resources/color_manageer.dart';
import '../resources/constatns.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_text_form_field.dart';
import 'sign_in_page.dart';

enum _ForgotStep { identifier, otp, newPassword }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const String routeName = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  _ForgotStep _step = _ForgotStep.identifier;
  String? _identifier;
  String? _resetToken;

  final _identifierFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = true;
  bool _confirmVisible = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _identifierValidator(String? value) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) return AppStrings.signInEmailValidatorError;
    final isPhone = str.isValidPhone ||
        str.isValidPhoneWithKeyCode ||
        str.startsWith('+967');
    if (EmailValidator.validate(str) || isPhone) return null;
    return AppStrings.signInEmailValidatorError;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.length < minCharsOfPassword) {
      return AppStrings.firebasePasswordValidatorError;
    }
    return null;
  }

  void _submitIdentifier() {
    if (_identifierFormKey.currentState?.validate() != true) return;
    final normalized = normalizeAuthIdentifier(_identifierController.text);
    if (normalized == null) return;
    _identifier = normalized;
    context.read<AuthBloc>().add(AuthForgotPasswordSubmitted(normalized));
  }

  void _submitOtp() {
    if (_otpFormKey.currentState?.validate() != true || _identifier == null) {
      return;
    }
    context.read<AuthBloc>().add(
          AuthOtpVerified(
            identifier: _identifier!,
            code: _otpController.text.trim(),
          ),
        );
  }

  void _submitNewPassword() {
    if (_passwordFormKey.currentState?.validate() != true ||
        _resetToken == null) {
      return;
    }
    context.read<AuthBloc>().add(
          AuthPasswordResetSubmitted(
            resetToken: _resetToken!,
            newPassword: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        title: const Text('استعادة كلمة المرور'),
        backgroundColor: ColorManager.primaryBg,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthForgotOtpSentNotice) {
            setState(() => _step = _ForgotStep.otp);
            Utils.showSnackBar(
              context: context,
              msg: 'إذا وُجد حساب مرتبط، سيُرسل رمز إلى بريدك المسجّل',
              color: ColorManager.secondary,
            );
          } else if (state is AuthReadyToChooseNewPassword) {
            setState(() {
              _resetToken = state.resetToken;
              _step = _ForgotStep.newPassword;
            });
          } else if (state is AuthPasswordResetFinishedNotice) {
            Utils.showSuccessSnackBar(
              context: context,
              msg: 'تم تعيين كلمة المرور. يمكنك تسجيل الدخول.',
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const SignInPage()),
              (_) => false,
            );
          } else if (state is AuthFailure) {
            Utils.showSnackBar(
              context: context,
              msg: state.message,
              color: ColorManager.error,
            );
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is AuthLoading,
            progressIndicator: const LoadingWidget(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: switch (_step) {
                _ForgotStep.identifier => _buildIdentifierStep(),
                _ForgotStep.otp => _buildOtpStep(),
                _ForgotStep.newPassword => _buildPasswordStep(),
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdentifierStep() {
    return Form(
      key: _identifierFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSize.s20),
          Text(
            'أدخل رقم هاتفك أو بريدك الإلكتروني',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s8),
          Text(
            'سيُرسل رمز التحقق إلى البريد المسجّل على حسابك. '
            'إذا لم يكن لحسابك بريد، أضفه أولاً من الإعدادات بعد تسجيل الدخول.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s24),
          MyTextFormField(
            controller: _identifierController,
            hint: AppStrings.signInEmailHint,
            validator: _identifierValidator,
            keyBoardType: TextInputType.emailAddress,
            blurrBorderColor: ColorManager.lightGrey,
            focusBorderColor: ColorManager.lightSecondary,
            fillColor: ColorManager.white,
            icon: const Icon(Icons.phone_android, color: ColorManager.primary),
          ),
          const SizedBox(height: AppSize.s30),
          MyButton(
            title: 'متابعة',
            color: Theme.of(context).primaryColor,
            titleStyle: Theme.of(context).textTheme.titleLarge,
            onPressed: _submitIdentifier,
            minWidth: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSize.s20),
          const Text(
            'أدخل رمز التحقق من بريدك المسجّل',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s24),
          MyTextFormField(
            controller: _otpController,
            hint: 'رمز من 6 أرقام',
            keyBoardType: TextInputType.number,
            blurrBorderColor: ColorManager.lightGrey,
            focusBorderColor: ColorManager.lightSecondary,
            fillColor: ColorManager.white,
            validator: (v) =>
                (v != null && v.length >= 6) ? null : 'رمز غير صالح',
          ),
          const SizedBox(height: AppSize.s30),
          MyButton(
            title: 'تأكيد',
            color: Theme.of(context).primaryColor,
            titleStyle: Theme.of(context).textTheme.titleLarge,
            onPressed: _submitOtp,
            minWidth: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSize.s20),
          const Text(
            'اختر كلمة مرور جديدة',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s24),
          MyTextFormField(
            controller: _passwordController,
            hint: 'كلمة المرور',
            isPassword: _passwordVisible,
            validator: _passwordValidator,
            blurrBorderColor: ColorManager.lightGrey,
            focusBorderColor: ColorManager.lightSecondary,
            fillColor: ColorManager.white,
            icon: IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
          const SizedBox(height: AppSize.s12),
          MyTextFormField(
            controller: _confirmPasswordController,
            hint: 'تأكيد كلمة المرور',
            isPassword: _confirmVisible,
            blurrBorderColor: ColorManager.lightGrey,
            focusBorderColor: ColorManager.lightSecondary,
            fillColor: ColorManager.white,
            validator: (v) =>
                v == _passwordController.text ? null : 'غير متطابقة',
            icon: IconButton(
              icon: Icon(
                _confirmVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _confirmVisible = !_confirmVisible),
            ),
          ),
          const SizedBox(height: AppSize.s30),
          MyButton(
            title: 'حفظ',
            color: Theme.of(context).primaryColor,
            titleStyle: Theme.of(context).textTheme.titleLarge,
            onPressed: _submitNewPassword,
            minWidth: double.infinity,
          ),
        ],
      ),
    );
  }
}
