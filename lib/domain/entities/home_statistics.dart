import 'package:flutter/material.dart';

List<HomeStatisticItem> statistics = <HomeStatisticItem>[
  HomeStatisticItem(title: "فصيلة B+", percentage: 40, color: Colors.blue),
  HomeStatisticItem(title: "فصيلة O+", percentage: 30, color: Colors.red),
  HomeStatisticItem(title: "فصيلة A+", percentage: 20, color: Colors.green),
  HomeStatisticItem(title: "أخرى", percentage: 10, color: Colors.yellow),
];

class HomeStatisticItem {
  final String title;
  final double percentage;
  final Color color;
  HomeStatisticItem(
      {required this.title, required this.percentage, required this.color});
}
