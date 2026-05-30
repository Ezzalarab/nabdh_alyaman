import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../core/utils.dart';
import '../../domain/entities/auth_session.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../resources/color_manageer.dart';
import '../resources/values_manager.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/forms/my_button.dart';
import '../widgets/forms/my_text_form_field.dart';
import '../auth/auth_navigation.dart';

class CompleteEmailPage extends StatefulWidget {
  const CompleteEmailPage({super.key, required this.session});

  static const String routeName = '/complete-email';

  final AuthenticatedSession session;

  @override
  State<CompleteEmailPage> createState() => _CompleteEmailPageState();
}

class _CompleteEmailPageState extends State<CompleteEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'أدخل البريد الإلكتروني';
    if (!EmailValidator.validate(trimmed)) return 'بريد إلكتروني غير صالح';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          AuthCompleteEmailSubmitted(
            email: _emailController.text.trim(),
            session: widget.session,
          ),
        );
  }

  void _skip() {
    context.read<AuthBloc>().add(AuthCompleteEmailSkipped(widget.session));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        title: const Text('ربط البريد'),
        backgroundColor: ColorManager.primaryBg,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Utils.showSuccessSnackBar(
              context: context,
              msg: 'تم حفظ البريد بنجاح',
            );
            navigateAfterAuth(context, state);
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSize.s20),
                    Text(
                      'أضف بريداً للربط بحسابك',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSize.s16),
                    Text(
                      'هذا ليس بالضرورة البريد الذي استخدمته سابقاً. '
                      'نحتاج بريداً لربط حسابك واستعادة كلمة المرور عند الحاجة.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSize.s30),
                    MyTextFormField(
                      controller: _emailController,
                      hint: 'البريد الإلكتروني',
                      keyBoardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                      blurrBorderColor: ColorManager.lightGrey,
                      focusBorderColor: ColorManager.lightSecondary,
                      fillColor: ColorManager.white,
                      icon: const Icon(Icons.email),
                    ),
                    const SizedBox(height: AppSize.s30),
                    MyButton(
                      title: 'حفظ البريد',
                      color: Theme.of(context).primaryColor,
                      titleStyle: Theme.of(context).textTheme.titleLarge,
                      onPressed: _submit,
                      minWidth: double.infinity,
                    ),
                    const SizedBox(height: AppSize.s12),
                    TextButton(
                      onPressed: _skip,
                      child: const Text('تخطي الآن'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
