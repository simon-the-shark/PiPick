import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "database/models.dart";
import "database/provider.dart";

part "acces_zone_repository.g.dart";

@riverpod
Future<AccessZone?> accessZoneRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.accessZones.get(2);
}
