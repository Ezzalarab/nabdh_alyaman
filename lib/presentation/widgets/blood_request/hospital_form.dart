import 'package:flutter/material.dart';

import '../forms/my_text_form_field.dart';

class HospitalFormFields extends StatelessWidget {
  const HospitalFormFields({
    super.key,
    required this.hospitalController,
    required this.patientController,
    required this.unitsController,
  });

  final TextEditingController hospitalController;
  final TextEditingController patientController;
  final TextEditingController unitsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextFormField(
          controller: hospitalController,
          hint: 'اسم المستشفى *',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'أدخل اسم المستشفى' : null,
        ),
        const SizedBox(height: 12),
        MyTextFormField(
          controller: patientController,
          hint: 'اسم المريض (اختياري)',
        ),
        const SizedBox(height: 12),
        MyTextFormField(
          controller: unitsController,
          hint: 'عدد الوحدات المطلوبة *',
          keyBoardType: TextInputType.number,
          validator: (v) {
            final n = int.tryParse(v?.trim() ?? '');
            if (n == null || n < 1) return 'أدخل عدداً صحيحاً (1 أو أكثر)';
            return null;
          },
        ),
      ],
    );
  }
}
