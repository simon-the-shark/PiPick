import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "admin_repository.g.dart";

@riverpod
class AdminRepository extends _$AdminRepository {
  @override
  Future<IList<Admin>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return (await isar.admins.where().findAll()).toIList();
  }

  Future<void> putAdmin(Admin admin) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.admins.put(admin);
    });
    ref.invalidateSelf();
  }

  Future<bool> isEmailUnique(String email) async {
    final isar = await ref.watch(isarProvider.future);
    return (await isar.admins.where().emailEqualTo(email).findAll()).isEmpty;
  }

  Future<bool> isLoginUnique(String login) async {
    final isar = await ref.watch(isarProvider.future);
    return (await isar.admins.where().loginEqualTo(login).findAll()).isEmpty;
  }
}
