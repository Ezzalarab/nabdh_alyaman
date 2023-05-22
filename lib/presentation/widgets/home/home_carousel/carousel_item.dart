import 'package:flutter/material.dart';

import '../../../../presentation/resources/color_manageer.dart';

class CarouselItem extends StatelessWidget {
  const CarouselItem({
    required this.item,
    Key? key,
  }) : super(key: key);
  final String item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      // padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
              color: ColorManager.grey2.withOpacity(0.3),
              blurRadius: 10.0,
              offset: Offset(2, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Container(
          child: Stack(
            children: <Widget>[
              Image.asset(item, fit: BoxFit.fill, width: 900.0),
            ],
          ),
        ),
      ),
    );
  }
}
