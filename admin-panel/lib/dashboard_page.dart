import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:isar/isar.dart";

import "./database/models.dart";

class DashboardPage extends StatefulWidget {
  final Isar isar;
  final AccessZone zone;

  const DashboardPage({
    super.key,
    required this.isar,
    required this.zone,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Logs> allLogs = [];
  List<Logs> failedLogs = [];
  Map<String, int> entriesFrequency = {};
  Map<String, int> failedEntriesFrequency = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final logs = await widget.isar.logs
        .filter()
        .zone(
          (q) => q.idEqualTo(widget.zone.id),
        )
        .findAll();

    setState(() {
      allLogs = logs;
      failedLogs = logs.where((log) => !log.successful).toList();
      processEntriesFrequency();
      processFailedEntriesFrequency();
    });
  }

  void processEntriesFrequency() {
    final Map<String, int> frequency = {};
    for (var log in allLogs) {
      final String day = DateFormat("yyyy-MM-dd").format(log.timestamp);
      frequency[day] = (frequency[day] ?? 0) + 1;
    }

    final sortedKeys = frequency.keys.toList()..sort();
    entriesFrequency = {for (final k in sortedKeys) k: frequency[k]!};
  }

  void processFailedEntriesFrequency() {
    final Map<String, int> frequency = {};
    for (final log in failedLogs) {
      final String day = DateFormat("yyyy-MM-dd").format(log.timestamp);
      frequency[day] = (frequency[day] ?? 0) + 1;
    }
    final sortedKeys = frequency.keys.toList()..sort();
    failedEntriesFrequency = {for (final k in sortedKeys) k: frequency[k]!};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard - ${widget.zone.location}",
        ),
      ),
      body: (allLogs.isEmpty && failedLogs.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Wykres częstotliwości wejść
                    Text(
                      "Częstotliwość Wejść - ${widget.zone.location}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LineChart(
                          buildLineChartData(
                            entriesFrequency,
                            Colors.blueAccent,
                            "Wejść",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Wykres nieudanych wejść
                    Text(
                      "Nieudane Wejścia - ${widget.zone.location}",
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
                        child: LineChart(
                          buildLineChartData(
                            failedEntriesFrequency,
                            Colors.redAccent,
                            "Nieudanych wejść",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  LineChartData buildLineChartData(
    Map<String, int> frequency,
    Color lineColor,
    String tooltipSuffix,
  ) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = frequency.keys.elementAt(spot.x.toInt());
              final value = spot.y.toInt();
              return LineTooltipItem(
                "$date\n$value $tooltipSuffix",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
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
                  axisSide: meta.axisSide,
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
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: frequency.entries
              .map(
                (e) => FlSpot(
                  frequency.keys.toList().indexOf(e.key).toDouble(),
                  e.value.toDouble(),
                ),
              )
              .toList(),
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          dotData: const FlDotData(show: true),
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
}
