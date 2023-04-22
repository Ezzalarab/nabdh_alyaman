import 'package:flutter/material.dart';

import '../../../../domain/entities/home_statistics.dart';

class IndicatorWidget extends StatelessWidget {
  const IndicatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statistics
            .map((data) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: buildIndicator(color: data.color, title: data.title),
                ))
            .toList(),
      );

  Widget buildIndicator({
    required Color color,
    required String title,
    bool isSquare = false,
    double size = 14,
    Color textColor = Colors.black87,
  }) =>
      Row(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: size,
              // fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      );
}
