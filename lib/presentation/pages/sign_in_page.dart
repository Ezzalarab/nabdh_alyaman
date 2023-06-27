import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../di.dart' as di;
import '../../core/extensions/extension.dart';
import '../../core/utils.dart';
import '../../data/models/dialod_reset_password.dart';
import '../cubit/signin_cubit/signin_cubit.dart';
import '../cubit/signup_cubit/signup_cubit.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../resources/constatns.dart';
import '../resources/font_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_text_form_field.dart';
import 'home_page.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  static const String routeName = "/sign-in";

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailState = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = true;
  String? smsCode;

  String? emailOrPhoneValidator(value) {
    String strValue = value?.toString() ?? "";
    bool isPhone = (strValue.isValidPhone || strValue.isValidPhoneWithKeyCode);
    if (value != null && (EmailValidator.validate(value) || isPhone)) {
      return null;
    } else if (!EmailValidator.validate(value!)) {
      return AppStrings.signInEmailValidatorError;
    }
    return null;
  }

  String? passwordValidator(value) {
    if (value!.length < minCharsOfPassword) {
      return AppStrings.firebasePasswordValidatorError;
    }
    return null;
  }

  _toggleIsPasswordVisible() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  _sendRestPassword() {
    if (_emailState.currentState!.validate()) {
      BlocProvider.of<SignInCubit>(context)
          .resetPassword(email: emailController.text);
    }
  }

  _submitSignIn() async {
    FocusScope.of(context).unfocus();
    if (_emailState.currentState!.validate() &
        _formState.currentState!.validate()) {
      BlocProvider.of<SignInCubit>(context).signIn(
        emailOrPhone: emailController.text,
        password: passwordController.text,
        onVerificationSent: showVerificationDialog(context),
      );
    }
  }

  Function showVerificationDialog(BuildContext context) {
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
                        BlocProvider.of<SignInCubit>(context, listen: false)
                            .verify(
                          smsCode: smsCode!,
                        );
                        Navigator.of(context).pop();
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

  _moveToSignUp() {
    di.initSignUp();
    BlocProvider.of<SignUpCubit>(context, listen: false)
        .checkCanSignUpWithPhone();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.signInAppBarTitle),
        elevation: AppSize.s0,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: BlocConsumer<SignInCubit, SignInState>(
          listener: (context, state) async {
            if (state is SignInSuccess) {
              // CheckActive.checkActiveUser();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()));
            } else if (state is SignInFailure) {
              Utils.showSnackBar(
                context: context,
                msg: state.error,
                color: ColorManager.error,
              );
            } else if (state is SignInSuccessResetPass) {
              DialogResetPassWord.resetPasswordDialog(context);
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: (state is SignInLoading),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSize.s30),
                    _buildHeaderImage(),
                    const SizedBox(height: AppSize.s20),
                    _buildSignInForm(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Form _buildSignInForm(BuildContext context) {
    return Form(
      key: _formState,
      child: Column(
        children: [
          _buildEmailField(context),
          const SizedBox(height: AppSize.s20),
          _buildPasswordField(context),
          _buildResetPasswordTextButton(context),
          const SizedBox(height: AppSize.s30),
          Column(
            children: [
              const SizedBox(width: AppSize.s50),
              _buildSubmitButton(context),
              // const SizedBox(width: AppSize.s20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 2.0,
                    color: ColorManager.grey2.withOpacity(0.5),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppMargin.m20),
                    height: 25,
                    child: const Text("أو"),
                  ),
                  Container(
                    width: 100,
                    height: 2.0,
                    color: ColorManager.grey2.withOpacity(0.5),
                  ),
                ],
              ),
              _buildSignUpButton(),
              const SizedBox(height: 20)
            ],
          ),
        ],
      ),
    );
  }

  Padding _buildHeaderImage() {
    return const Padding(
      padding: EdgeInsets.all(AppPadding.p10),
      child: Stack(
        children: [
          SizedBox(
            height: signInImageHight,
            child: CircleAvatar(
              backgroundImage: AssetImage(ImageAssets.signInImage),
              radius: signInImageRadius,
            ),
          ),
          Positioned(
            bottom: AppSize.s8,
            right: AppSize.s0,
            child: Icon(
              Icons.add,
              size: AppSize.s70,
              color: ColorManager.white,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildEmailField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppMargin.m40),
      child: Form(
        key: _emailState,
        child: MyTextFormField(
          hint: AppStrings.signInEmailHint,
          controller: emailController,
          blurrBorderColor: ColorManager.lightGrey,
          focusBorderColor: ColorManager.secondary,
          fillColor: ColorManager.white,
          validator: emailOrPhoneValidator,
          keyBoardType: TextInputType.emailAddress,
          icon: const Icon(
            Icons.phone_android,
            color: ColorManager.primary,
          ),
        ),
      ),
    );
  }

  Container _buildPasswordField(BuildContext context) {
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
          icon: _buildPasswordIcon(),
          color: ColorManager.primary,
          onPressed: _toggleIsPasswordVisible,
        ),
      ),
    );
  }

  Container _buildResetPasswordTextButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p50,
        vertical: AppPadding.p10,
      ),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _sendRestPassword,
        child: Text(
          AppStrings.signInForgetPasswordTextButton,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: ColorManager.link,
              ),
        ),
      ),
    );
  }

  Icon _buildPasswordIcon() {
    return Icon(isPasswordVisible
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined);
  }

  MyButton _buildSubmitButton(BuildContext context) {
    return MyButton(
      title: AppStrings.signInSubmitButton,
      color: Theme.of(context).primaryColor,
      titleStyle: Theme.of(context).textTheme.titleLarge,
      onPressed: _submitSignIn,
      minWidth: AppSize.s300,
    );
  }

  MyButton _buildSignUpButton() {
    return MyButton(
      title: AppStrings.signInSignUpButton,
      color: ColorManager.grey1,
      onPressed: _moveToSignUp,
      minWidth: AppSize.s300,
      titleStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: FontSize.s14,
        fontFamily: FontConstants.fontFamily,
      ),
    );
  }
}

// forget password onTap 
// if (_formStateEmail.currentState!.validate()) {
// _formStateEmail.currentState!.save();
//   if (email!.isValidPhone) {
//     BlocProvider.of<SingInCubit>(context)
//         .isPhoneRegisterd(
//             phone: email!, type: "forget");
//   }

// signin button onPress
  // if (_formState.currentState!.validate() &&
  //     _formStateEmail.currentState!
  //         .validate()) {
  //   _formState.currentState!.save();
  //   _formStateEmail.currentState!.save();
  //   if (email!.isValidPhone) {
  //     BlocProvider.of<SingInCubit>(context)
  //         .isPhoneRegisterd(
  //             phone: email!,
  //             type: "signin",
  //             password: password!);
  //   } else {
  //     BlocProvider.of<SingInCubit>(context)
  //         .signIn(
  //             email: email!,
  //             password: password!);
  //   }
  // }