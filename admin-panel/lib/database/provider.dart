import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "models.dart";

part "provider.g.dart";

@Riverpod(keepAlive: true) // singleton
Future<Isar> isar(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory();

  return Isar.open(
    [UserSchema, AdminSchema, AccessZoneSchema, LogsSchema],
    directory: dir.path,
  );
}
