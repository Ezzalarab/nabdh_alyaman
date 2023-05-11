import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static String removeCountryKeyFormPhone(String phoneWithCode) {
    int numbersCount = phoneWithCode.length;
    return phoneWithCode.substring(numbersCount - 9, numbersCount);
  }

  static String getCurrentDate() {
    // Get the current date
    final now = DateTime.now();

    // Format the date as "yyyy-MM-dd"
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);

    // Return the formatted date string
    return formattedDate;
  }
}
