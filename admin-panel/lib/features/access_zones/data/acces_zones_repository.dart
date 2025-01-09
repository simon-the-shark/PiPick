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
}
