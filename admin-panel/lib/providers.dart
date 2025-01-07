// lib/providers.dart

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

import "database/models.dart";

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError();
});

final isarFutureProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  return Isar.open(
    [UserSchema, AdminSchema, AccessZoneSchema, LogsSchema],
    directory: dir.path,
  );
});

final accessZoneProvider = FutureProvider<AccessZone>((ref) async {

  final isar = await ref.watch(isarFutureProvider.future);

  AccessZone? zone = await isar.accessZones.get(2);

  if (zone == null) {
    zone = AccessZone()
      ..number = 10
      ..location = "Domyślna Lokalizacja";

    await isar.writeTxn(() async {
      await isar.accessZones.put(zone!);
    });
  }

  return zone;
});
