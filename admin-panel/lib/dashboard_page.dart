// lib/dashboard_page.dart

import "dart:async";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:intl/intl.dart";
import "package:isar/isar.dart";

import "./database/models.dart";
import "./providers.dart";

class DashboardPage extends HookConsumerWidget {
  const DashboardPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsyncValue = ref.watch(isarFutureProvider);

    final accessZoneAsyncValue = ref.watch(accessZoneProvider);

    final allLogs = useState<List<Logs>>([]);
    final failedLogs = useState<List<Logs>>([]);
    final entriesFrequency = useState<Map<String, int>>({});
    final failedEntriesFrequency = useState<Map<String, int>>({});
    final isLoading = useState<bool>(true);
    final error = useState<String?>(null);

    useEffect(() {
      if (isarAsyncValue is AsyncData<Isar> &&
          accessZoneAsyncValue is AsyncData<AccessZone>) {
        Future<void> fetchData() async {
          try {
            final isar = isarAsyncValue.value;
            final zone = accessZoneAsyncValue.value;
            final logs = await isar.logs
                .filter()
                .zone((q) => q.idEqualTo(zone.id))
                .findAll();

            final successfulLogs = logs;
            final failed = logs.where((log) => !log.successful).toList();

            final freq = <String, int>{};
            for (final log in successfulLogs) {
              final day = DateFormat("yyyy-MM-dd").format(log.timestamp);
              freq[day] = (freq[day] ?? 0) + 1;
            }
            final sortedKeys = freq.keys.toList()..sort();
            final sortedFreq = {for (final k in sortedKeys) k: freq[k]!};

            final failedFreq = <String, int>{};
            for (final log in failed) {
              final day = DateFormat("yyyy-MM-dd").format(log.timestamp);
              failedFreq[day] = (failedFreq[day] ?? 0) + 1;
            }
            final sortedFailedKeys = failedFreq.keys.toList()..sort();
            final sortedFailedFreq = {
              for (final k in sortedFailedKeys) k: failedFreq[k]!,
            };

            allLogs.value = successfulLogs;
            failedLogs.value = failed;
            entriesFrequency.value = sortedFreq;
            failedEntriesFrequency.value = sortedFailedFreq;
          } catch (e) {
            error.value = "Failed to fetch logs: $e";
          } finally {
            isLoading.value = false;
          }
        }

        unawaited(fetchData());
      }

      return null;
    }, [isarAsyncValue, accessZoneAsyncValue]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : allLogs.value.isEmpty && failedLogs.value.isEmpty
              ? const Center(child: Text("No Logs Available"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // Frequency of Entries Chart
                        Text(
                          "Częstotliwość Wejść - ${accessZoneAsyncValue.asData?.value.location ?? ''}",
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
                                entriesFrequency.value,
                                Colors.blueAccent,
                                "Wejść",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Failed Entries Chart
                        Text(
                          "Nieudane Wejścia - ${accessZoneAsyncValue.asData?.value.location ?? ''}",
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
                                failedEntriesFrequency.value,
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
                  frequency.keys.toList().indexOf(e.key).toDouble(),
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
}
