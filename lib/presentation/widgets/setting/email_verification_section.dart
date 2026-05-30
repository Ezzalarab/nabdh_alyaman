import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils.dart';
import '../../../domain/entities/donor.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import '../forms/my_button.dart';
import '../forms/my_text_form_field.dart';

class EmailVerificationSection extends StatelessWidget {
  const EmailVerificationSection({super.key, required this.donor});

  final Donor donor;

  bool get _shouldShow =>
      donor.email.isNotEmpty && !donor.emailVerified && !donor.emailMissing;

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow && !donor.emailVerified) {
      if (donor.emailMissing) {
        return _buildInfoCard(
          context,
          icon: Icons.mail_outline,
          text:
              'لم تربط بريداً بعد. يمكنك إضافته لاحقاً من تسجيل الدخول أو التواصل مع الدعم.',
        );
      }
      return const SizedBox.shrink();
    }

    if (donor.emailVerified) {
      return _buildInfoCard(
        context,
        icon: Icons.verified_outlined,
        text: 'بريدك الإلكتروني مُتحقّق',
        color: ColorManager.success,
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailVerificationSent) {
          _showOtpDialog(context);
        } else if (state is AuthEmailVerifiedSuccess) {
          Utils.showSuccessSnackBar(
            context: context,
            msg: 'تم التحقق من بريدك بنجاح',
          );
          context.read<ProfileBloc>().add(ProfileLoadRequested());
        } else if (state is AuthFailure) {
          Utils.showSnackBar(
            context: context,
            msg: state.message,
            color: ColorManager.error,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p30,
          vertical: AppPadding.p10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التحقق من البريد (اختياري)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSize.s8),
            Text(
              donor.email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSize.s12),
            MyButton(
              title: 'إرسال رمز التحقق',
              color: ColorManager.secondary,
              titleStyle: Theme.of(context).textTheme.titleMedium,
              minWidth: double.infinity,
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(AuthSendEmailVerificationRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p30,
        vertical: AppPadding.p10,
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? ColorManager.grey),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog(BuildContext context) {
    final key = GlobalKey<FormState>();
    final controller = TextEditingController();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      btnOkText: 'تأكيد',
      btnCancelText: 'إلغاء',
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل رمز التحقق المرسل إلى بريدك',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                controller: controller,
                hint: 'رمز من 6 أرقام',
                keyBoardType: TextInputType.number,
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
        if (key.currentState?.validate() != true) return;
        context.read<AuthBloc>().add(
              AuthVerifyEmailSubmitted(controller.text.trim()),
            );
      },
      btnCancelOnPress: () {},
    ).show();
  }
}
