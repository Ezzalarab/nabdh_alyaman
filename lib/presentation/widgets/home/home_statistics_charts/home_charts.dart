import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/home_statistics.dart';
import 'indicator_widget.dart';

class HomeCharts extends StatelessWidget {
  const HomeCharts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: const [
                Text(
                  "حسب البيانات المسجلة في التطبيق",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: IndicatorWidget(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          width: 150,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 20,
              sectionsSpace: 0,
              sections: getSections(),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> getSections() => statistics
      .asMap()
      .map<int, PieChartSectionData>((index, data) {
        final value = PieChartSectionData(
          color: data.color,
          value: data.percentage,
          title: "${data.percentage.toInt()}%",
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
        return MapEntry(index, value);
      })
      .values
      .toList();
}
