import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "users_repository.g.dart";

@riverpod
class UsersRepository extends _$UsersRepository {
  @override
  Future<List<User>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return isar.users.where().findAll();
  }

  Future<void> addUser(User user) async {
    final isar = await ref.watch(isarProvider.future);
    await isar.writeTxn(() async {
      return isar.users.put(user);
    });
    ref.invalidateSelf();
  }
}
