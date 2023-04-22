import 'package:flutter/material.dart';

class MyOutlinedIconButton extends StatelessWidget {
  const MyOutlinedIconButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderWidth = 2,
    this.borderColor = Colors.blue,
    Key? key,
  }) : super(key: key);

  final double borderWidth;
  final Color borderColor;
  final Widget label;
  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              width: borderWidth,
              color: borderColor,
            ),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
      label: label,
      icon: icon ?? Container(),
      onPressed: onPressed,
    );
  }
}
