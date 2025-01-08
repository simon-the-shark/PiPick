import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "database/models.dart";
import "database/provider.dart";

part "acces_zones_repository.g.dart";

@riverpod
Future<AccessZone?> exampleAccessZoneRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.accessZones.get(2);
}

@riverpod
Future<List<AccessZone>> allAccessZonesRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.accessZones.where().findAll();
}
