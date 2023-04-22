import '../../../presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import '../../resources/color_manageer.dart';
import '../../resources/font_manager.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.isPrefexIcon = false,
    this.color = ColorManager.secondary,
    this.contentPadding = const EdgeInsets.all(0.0),
    this.height = 40,
    this.raduis = 10,
    this.minWidth = 200,
    this.titleStyle = const TextStyle(
      fontSize: FontSize.s14,
      color: ColorManager.black,
      fontFamily: FontConstants.fontFamily,
    ),
  });
  final Color color;
  final double height, raduis, minWidth;
  final String title;
  final VoidCallback onPressed;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry contentPadding;
  final bool isPrefexIcon;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        elevation: AppSize.s4,
        color: color,
        borderRadius: BorderRadius.circular(15),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: minWidth,
          height: height,
          child: Padding(
            padding: contentPadding,
            child: icon == null
                ? Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  )
                : Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isPrefexIcon
                          ? FittedBox(
                              fit: BoxFit.contain,
                              child: icon!,
                            )
                          : const SizedBox(),
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: titleStyle,
                        ),
                      ),
                      isPrefexIcon
                          ? const SizedBox()
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: icon!,
                            ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
