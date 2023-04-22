import 'package:flutter/material.dart';

class MyDropdownButtonFormField extends StatelessWidget {
  const MyDropdownButtonFormField({
    Key? key,
    required this.value,
    required this.onChange,
    required this.items,
    this.icon = const Icon(Icons.menu),
    this.hint = 'Select an item',
    this.focusBorderColor = Colors.green,
    this.blurrBorderColor = Colors.blue,
    this.hintColor = Colors.black87,
    this.fillColor,
    this.style,
    this.raduis = 10,
    this.validator,
  }) : super(key: key);

  final String hint;
  final String? value;
  final TextStyle? style;
  final Icon icon;
  final Color focusBorderColor, blurrBorderColor, hintColor;
  final Color? fillColor;
  final List<String> items;
  final Function(String?)? onChange;
  final double raduis;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      validator: validator,
      hint: Text(
        hint,
        style: TextStyle(
          color: hintColor,
        ),
      ),
      style: style,
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
              ),
            ),
          )
          .toList(),
      onChanged: onChange,
      decoration: InputDecoration(
        prefixIcon: icon,
        filled: (fillColor != null),
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(raduis),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: blurrBorderColor,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: focusBorderColor,
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
