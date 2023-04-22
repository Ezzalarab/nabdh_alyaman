import 'package:flutter/material.dart';

import '../../resources/style.dart';

class MySwitchListTile extends StatelessWidget {
  const MySwitchListTile({
    Key? key,
    required this.title,
    this.subTitle,
    required this.onChange,
    this.style,
    this.onchangValue = false,
  }) : super(key: key);
  final String title;
  final String? subTitle;
  final bool onchangValue;
  final ValueChanged<bool>? onChange;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
      child: SwitchListTile(
        title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              style: style,
            )),
        subtitle: Text(
          subTitle!,
          style: Theme.of(context).textTheme.titleMedium!,
        ),
        value: onchangValue,
        activeColor: eSecondColor,
        onChanged: onChange,
      ),
    );
  }
}
