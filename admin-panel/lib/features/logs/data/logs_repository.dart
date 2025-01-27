import "dart:math";

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
Future<IList<Logs>> logsByZoneRepository(Ref ref, int zoneId) async {
  final isar = await ref.watch(isarProvider.future);
  final logs =
      await isar.logs.filter().zone((q) => q.idEqualTo(zoneId)).findAll();
  return logs.toIList();
}

Seeder generateRandomLogs(Ref ref) {
  return (int zoneId) async {
    final isar = await ref.watch(isarProvider.future);
    final random = Random();
    final now = DateTime.now();
    final logs = <Logs>[];

    for (int i = 0; i < 10; i++) {
      final day = now.subtract(Duration(days: i));
      final numberOfLogs = random.nextInt(250) + 1;

      for (int j = 0; j < numberOfLogs; j++) {
        final isSuccess = random.nextBool();
        final log = Logs()
          ..zone.value = await isar.accessZones.get(zoneId)
          ..timestamp = day
          ..successful = isSuccess
          ..rfidCard = "RFID${random.nextInt(1000)}"
          ..user.value = await isar.users.where().findFirst()
          ..message = isSuccess ? "Seeded Wjazd" : "Seeded Wyjazd";
        logs.add(log);
      }
    }

    await isar.writeTxn(() async {
      await isar.logs.putAll(logs);
      for (final log in logs) {
        await log.user.save();
        await log.zone.save();
      }
    });
  };
}

typedef Seeder = Future<void> Function(int zoneId);

@riverpod
Seeder seeder(Ref ref) {
  return generateRandomLogs(ref);
}
