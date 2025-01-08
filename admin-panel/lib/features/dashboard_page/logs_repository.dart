import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../database/models.dart";
import "../../database/provider.dart";

part "logs_repository.g.dart";

@riverpod
Future<List<Logs>> allLogs(Ref ref, int zoneId) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.logs.filter().zone((q) => q.idEqualTo(zoneId)).findAll();
}

@riverpod
FutureOr<List<Logs>> failedLogs(FailedLogsRef ref, int zoneId) async {
  final allLogs = await ref.watch(allLogsProvider(zoneId).future);
  return allLogs.where((log) => !log.successful).toList();
}

@riverpod
FutureOr<Map<String, int>> entriesRequency(Ref ref, int zoneId) async {
  final allLogs = await ref.watch(allLogsProvider(zoneId).future);
  final freq = <String, int>{};
  for (final log in allLogs) {
    final day = DateFormat("yyyy-MM-dd").format(log.timestamp);
    freq[day] = (freq[day] ?? 0) + 1;
  }
  final sortedKeys = freq.keys.toList()..sort();
  return {for (final k in sortedKeys) k: freq[k]!};
}

@riverpod
FutureOr<Map<String, int>> failedEntriesFrequency(Ref ref, int zoneId) async {
  final failed = await ref.watch(failedLogsProvider(zoneId).future);
  final failedFreq = <String, int>{};
  for (final log in failed) {
    final day = DateFormat("yyyy-MM-dd").format(log.timestamp);
    failedFreq[day] = (failedFreq[day] ?? 0) + 1;
  }
  final sortedFailedKeys = failedFreq.keys.toList()..sort();
  return {for (final k in sortedFailedKeys) k: failedFreq[k]!};
}
