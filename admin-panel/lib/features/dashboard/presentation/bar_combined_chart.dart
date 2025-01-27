import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

import "bar_chart_data.dart";

typedef CombinedFreqs = IMap<String, ({int? failed, int? success})>;

CombinedFreqs combineMaps(
  IMap<String, int> entriesFrequency,
  IMap<String, int> failedEntriesFrequency,
) {
  final combinedMap = <String, ({int? failed, int? success})>{};
  final combinedKeys = Set<String>.from(entriesFrequency.keys)
      .union(Set<String>.from(failedEntriesFrequency.keys));
  for (final key in combinedKeys) {
    combinedMap[key] =
        (failed: failedEntriesFrequency[key], success: entriesFrequency[key]);
  }
  return combinedMap.toIMap();
}

class BarCombinedChart extends HookWidget {
  const BarCombinedChart({
    required this.entriesFrequency,
    required this.failedEntriesFrequency,
    super.key,
  });

  final IMap<String, int> entriesFrequency;
  final IMap<String, int> failedEntriesFrequency;

  @override
  Widget build(BuildContext context) {
    final combineFreqs = useMemoized(
      () => combineMaps(entriesFrequency, failedEntriesFrequency),
      [entriesFrequency, failedEntriesFrequency],
    );
    return BarChart(
      buildBarChartData(combineFreqs),
    );
  }
}
