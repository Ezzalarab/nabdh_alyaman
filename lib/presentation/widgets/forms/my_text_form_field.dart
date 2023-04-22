import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField(
      {Key? key,
      this.hint,
      this.style,
      this.icon,
      this.keyBoardType = TextInputType.text,
      this.onChange,
      this.validator,
      this.onSave,
      this.focusBorderColor,
      this.blurrBorderColor,
      this.fillColor,
      this.hintStyle = const TextStyle(),
      this.isPassword = false,
      this.suffixIcon = true,
      this.readOnly = false,
      this.onTap,
      this.controller,
      this.initialValue})
      : super(key: key);

  final TextInputType keyBoardType;
  final TextStyle? style;
  final String? hint;
  final ValueChanged<String>? onChange;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSave;
  final Widget? icon;
  final bool suffixIcon;
  final Color? focusBorderColor, blurrBorderColor, fillColor;
  final bool isPassword;
  final TextStyle hintStyle;
  final bool readOnly;
  final TextEditingController? controller;
  final String? initialValue;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onTap: onTap,
      onChanged: onChange,
      validator: validator,
      obscureText: isPassword,
      onSaved: onSave,
      keyboardType: keyBoardType,
      textAlign: TextAlign.center,
      readOnly: readOnly,
      style: style,
      decoration: InputDecoration(
        prefixIcon: suffixIcon
            ? null
            : icon != null
                ? icon!
                : null,
        suffixIcon: suffixIcon ? icon : null,
        hintText: hint,
        hintStyle: hintStyle,
        filled: (fillColor != null),
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: blurrBorderColor ?? Colors.blue[800]!,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: focusBorderColor ?? Colors.green,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
