import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "logs_repository.g.dart";

@riverpod
Future<IList<Logs>> allLogsRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  // POTEZNY QUERRY final test = await isar.logs.filter().zone((q) => q.numberEqualTo(10)).user((q) => q.nameEqualTo("Anna")).timestampBetween(lower, upper).sortByTimestamp().findAll();
  return (await isar.logs.where().findAll()).toIList();
}

@riverpod
Future<IList<Logs>> logsByZoneRepository(Ref ref, int zoneNumber) async {
  final isar = await ref.watch(isarProvider.future);
  return (await isar.logs
          .filter()
          .zone((q) => q.numberEqualTo(zoneNumber))
          .findAll())
      .toIList();
}
