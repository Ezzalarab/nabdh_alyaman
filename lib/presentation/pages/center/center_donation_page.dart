import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils.dart';
import '../../blocs/center/center_bloc.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/my_button.dart';
import '../../widgets/forms/my_text_form_field.dart';

class CenterDonationPage extends StatefulWidget {
  const CenterDonationPage({super.key});

  static const String routeName = 'center_donation';

  @override
  State<CenterDonationPage> createState() => _CenterDonationPageState();
}

class _CenterDonationPageState extends State<CenterDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _donorIdController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _donorIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل تبرع')),
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
              msg: state.message ?? 'تم تسجيل التبرع',
              color: ColorManager.success,
            );
            _donorIdController.clear();
            _notesController.clear();
          }
        },
        builder: (context, state) {
          if (state is CenterLoading) {
            return const Center(child: LoadingWidget());
          }
          return Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'أدخل معرّف المتبرع (رقم المستخدم) كما يظهر في نتائج البحث.',
                  ),
                  const SizedBox(height: AppSize.s16),
                  MyTextFormField(
                    controller: _donorIdController,
                    hint: 'معرّف المتبرع',
                    keyBoardType: TextInputType.number,
                    validator: (value) {
                      final id = int.tryParse(value?.trim() ?? '');
                      if (id == null || id <= 0) {
                        return 'أدخل معرّفاً صحيحاً';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSize.s16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'ملاحظات (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSize.s24),
                  MyButton(
                    title: 'تسجيل التبرع',
                    color: ColorManager.secondary,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      final donorId =
                          int.parse(_donorIdController.text.trim());
                      context.read<CenterBloc>().add(
                            CenterDonationRecordSubmitted(
                              donorId: donorId,
                              notes: _notesController.text.trim().isEmpty
                                  ? null
                                  : _notesController.text.trim(),
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
