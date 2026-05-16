import 'package:flutter/material.dart';

import '../resources/color_manageer.dart';

/// المراكز لا تُنشأ ذاتياً في التطبيق — الحساب يُنشأ من الإدارة.
class SignUpCenter extends StatelessWidget {
  const SignUpCenter({super.key});
  static const String routeName = 'sign-up-center';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        title: const Text('مركز طبي'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'إنشاء حساب مركز الدم لا يتم عبر هذا التطبيق.\n'
            'يقوم فريق نبض اليمن بتزويد مركزكم ببيانات الدخول بعد التنسيق الإداري.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
