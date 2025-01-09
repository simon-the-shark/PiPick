import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "users_repository.g.dart";

@riverpod
class UsersRepository extends _$UsersRepository {
  @override
  Future<IList<User>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return (await isar.users.where().findAll()).toIList();
  }

  Future<void> putUser(User user) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      return isar.users.put(user);
    });
    ref.invalidateSelf();
  }

  Future<void> deleteUser(int id) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      return isar.users.delete(id);
    });
    ref.invalidateSelf();
  }

  Future<bool> isPhoneUnique(String phone) async {
    final isar = await ref.watch(isarProvider.future);
    final existingUser =
        await isar.users.filter().phoneEqualTo(phone).findFirst();
    return existingUser == null;
  }
}
