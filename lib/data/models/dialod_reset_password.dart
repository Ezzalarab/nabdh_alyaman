import 'package:flutter/material.dart';

import '../../presentation/resources/strings_manager.dart';
import '../../presentation/widgets/forms/my_button.dart';

class DialogResetPassWord {
  static void resetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.resetPasswordDialogTitle),
        content: Text(
          AppStrings.resetPasswordDialogMessage,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.5),
        ),
        actions: <Widget>[
          Center(
            child: MyButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              title: AppStrings.resetPasswordDialogOkButton,
              titleStyle: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
