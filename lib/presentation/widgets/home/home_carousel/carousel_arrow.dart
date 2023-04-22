import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';

import '../../../resources/style.dart';

class CarouselArrow extends StatelessWidget {
  const CarouselArrow(
      {Key? key, required CarouselController controller, required this.icon})
      : _controller = controller,
        super(key: key);

  final CarouselController _controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 50,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            backgroundColor: Colors.red.withOpacity(0),
            shadowColor: Colors.red.withOpacity(0),
          ),
          child: SizedBox(
            height: 200,
            child: Icon(
              icon,
              size: 40,
              color: eSecondColor.withOpacity(0.4),
            ),
          ),
          onPressed: () {
            _controller.nextPage();
          },
        ),
      ),
    );
  }
}
