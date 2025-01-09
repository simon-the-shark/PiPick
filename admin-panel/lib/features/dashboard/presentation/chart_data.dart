import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

LineChartData buildLineChartData(
  IMap<String, int> frequency,
  Color lineColor,
  String tooltipSuffix,
) {
  return LineChartData(
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
          final date = frequency.keys.elementAt(spot.x.toInt());
          final value = spot.y.toInt();
          return LineTooltipItem(
            "$date\n$value $tooltipSuffix",
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
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
            if (index >= 0 && index < frequency.keys.length) {
              final text = frequency.keys.elementAt(index);
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
          interval: 1,
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
    lineBarsData: [
      LineChartBarData(
        spots: frequency.entries
            .map(
              (e) => FlSpot(
                frequency.keys.toIList().indexOf(e.key).toDouble(),
                e.value.toDouble(),
              ),
            )
            .toList(),
        isCurved: true,
        color: lineColor,
        barWidth: 3,
      ),
    ],
    minX: 0,
    maxX: (frequency.keys.length - 1).toDouble(),
    minY: 0,
    maxY: frequency.values.isNotEmpty
        ? (frequency.values.reduce((a, b) => a > b ? a : b).toDouble()) + 1
        : 10,
  );
}
