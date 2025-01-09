import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "logs_by_zone_repository.g.dart";

@riverpod
Future<IList<Logs>> allLogsByZone(Ref ref, int zoneId) async {
  final isar = await ref.watch(isarProvider.future);
  return (await isar.logs.filter().zone((q) => q.idEqualTo(zoneId)).findAll())
      .toIList();
}

@riverpod
Future<IList<Logs>> failedLogsByZone(Ref ref, int zoneId) async {
  final allLogs = await ref.watch(allLogsByZoneProvider(zoneId).future);
  return allLogs.where((log) => !log.successful).toIList();
}

@riverpod
Future<IMap<String, int>> entriesRequency(Ref ref, int zoneId) async {
  final allLogs = await ref.watch(allLogsByZoneProvider(zoneId).future);
  final freq = <String, int>{};
  for (final log in allLogs) {
    final day = DateFormat("yyyy-MM-dd").format(log.timestamp);
    freq[day] = (freq[day] ?? 0) + 1;
  }
  final sortedKeys = freq.keys.toList()..sort();
  return {for (final k in sortedKeys) k: freq[k]!}.toIMap();
}

@riverpod
FutureOr<IMap<String, int>> failedEntriesFrequency(Ref ref, int zoneId) async {
  final failed = await ref.watch(failedLogsByZoneProvider(zoneId).future);
  final failedFreq = <String, int>{};
  for (final log in failed) {
    final day = DateFormat("yyyy-MM-dd").format(log.timestamp);
    failedFreq[day] = (failedFreq[day] ?? 0) + 1;
  }
  final sortedFailedKeys = failedFreq.keys.toList()..sort();
  return {for (final k in sortedFailedKeys) k: failedFreq[k]!}.toIMap();
}
