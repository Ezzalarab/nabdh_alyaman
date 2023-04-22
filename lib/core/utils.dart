import 'package:flutter/material.dart';

import '../presentation/resources/color_manageer.dart';

class Utils {
  static void showSnackBar({
    required BuildContext context,
    required String msg,
    Color? color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  static void showSuccessSnackBar({
    required BuildContext context,
    required String msg,
    Color color = ColorManager.success,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  static void showFalureSnackBar({
    required BuildContext context,
    required String msg,
    Color color = ColorManager.error,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }
}
