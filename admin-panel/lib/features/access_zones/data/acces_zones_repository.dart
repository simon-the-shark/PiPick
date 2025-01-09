import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "acces_zones_repository.g.dart";

@riverpod
class AccessZonesRepository extends _$AccessZonesRepository {
  @override
  FutureOr<List<AccessZone>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return isar.accessZones.where().findAll();
  }

  Future<void> putZone(AccessZone zone) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.accessZones.put(zone);
    });
    ref.invalidateSelf();
  }

  Future<void> deleteZone(Id id) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.accessZones.delete(id);
    });
    ref.invalidateSelf();
  }

  Future<bool> checkIfNumberIsUnique(int number) async {
    final isar = await ref.watch(isarProvider.future);
    final existingZone =
        await isar.accessZones.filter().numberEqualTo(number).findFirst();
    return existingZone == null;
  }
}
