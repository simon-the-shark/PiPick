import "package:collection/collection.dart";
import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "acces_zones_repository.g.dart";

@riverpod
class AccessZonesRepository extends _$AccessZonesRepository {
  @override
  Future<IList<AccessZone>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return (await isar.accessZones.where().findAll()).toIList();
  }

  Future<void> putZone(AccessZone zone, [IList<User>? allowedUsers]) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.accessZones.put(zone);
      await zone.zoneAllowedUsers.load();
      if (allowedUsers != null) {
        final usersToAdd = allowedUsers
            .where(
              (user) => zone.zoneAllowedUsers.none(
                (allowedUser) => allowedUser.id == user.id,
              ),
            )
            .toIList();
        for (final user in usersToAdd) {
          user.allowedZones.add(zone);
          await user.allowedZones.save();
        }

        final usersToRemove = zone.zoneAllowedUsers
            .where(
              (user) =>
                  allowedUsers.none((allowedUser) => allowedUser.id == user.id),
            )
            .toIList();
        for (final user in usersToRemove) {
          user.allowedZones.remove(zone);
          await user.allowedZones.save();
        }
      }
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

  Future<bool> isNumberUnique(int number) async {
    final isar = await ref.watch(isarProvider.future);
    final existingZone =
        await isar.accessZones.filter().numberEqualTo(number).findFirst();
    return existingZone == null;
  }
}
