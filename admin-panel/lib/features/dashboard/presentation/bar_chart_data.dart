import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

import "bar_combined_chart.dart";

BarChartData buildBarChartData(
  CombinedFreqs frequencies,
) {
  return BarChartData(
    barTouchData: BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final date = frequencies.keys.elementAt(group.x);
          final value = rod.toY.toInt();
          final tooltipSuffix = rodIndex == 0 ? "Nieudanych Wejść" : "Wejść";
          return BarTooltipItem(
            "$date\n$value $tooltipSuffix",
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    ),
    gridData: FlGridData(
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.shade300,
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: Colors.grey.shade300,
        strokeWidth: 1,
      ),
    ),
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int index = value.toInt();
            if (index >= 0 && index < frequencies.keys.length) {
              final text = frequencies.keys.elementAt(index);
              return SideTitleWidget(
                meta: meta,
                child: Transform.rotate(
                  angle: -30 * 3.1415927 / 180,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: (frequencies.values.isNotEmpty
              ? (frequencies.values
                      .map(
                        (e) => (e.failed ?? 0) > (e.success ?? 0)
                            ? (e.failed ?? 0)
                            : (e.success ?? 0),
                      )
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble()) /
                  4
              : 2.0),
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 11),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    barGroups: [
      ...frequencies.entries.map(
        (e) => BarChartGroupData(
          x: frequencies.keys.toIList().indexOf(e.key),
          barRods: [
            if (e.value.failed != null)
              BarChartRodData(
                toY: e.value.failed!.toDouble(),
                color: Colors.redAccent,
              ),
            if (e.value.success != null)
              BarChartRodData(
                toY: e.value.success!.toDouble(),
                color: Colors.blue,
              ),
          ],
        ),
      ),
    ],
    minY: 0,
    maxY: frequencies.values.isNotEmpty
        ? (frequencies.values
                .map(
                  (e) => (e.failed ?? 0) > (e.success ?? 0)
                      ? (e.failed ?? 0)
                      : (e.success ?? 0),
                )
                .reduce((a, b) => a > b ? a : b)
                .toDouble()) +
            1
        : 10,
  );
}
