import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

import "bar_chart_data.dart";

class FrequenciesChart extends StatelessWidget {
  const FrequenciesChart({
    super.key,
    required this.freqMap,
    required this.label,
    required this.color,
    required this.header,
  });

  final IMap<String, int> freqMap;
  final String label;
  final Color color;
  final String header;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          header,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BarChart(
              buildBarChartData(
                freqMap,
                color,
                label,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
