import "package:bcrypt/bcrypt.dart";
import "package:isar/isar.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";

part "admin_repository.g.dart";

@riverpod
class AdminRepository extends _$AdminRepository {
  @override
  Future<void> build() async {
    // creates an admin with login "admin" and password "admin" if it doesn't exist
    final isar = await ref.watch(isarProvider.future);
    final adminExists =
        await isar.admins.where().loginEqualTo("admin").findFirst();
    if (adminExists == null) {
      final admin = Admin()
        ..login = "admin"
        ..password = BCrypt.hashpw("admin", BCrypt.gensalt())
        ..name = "admin"
        ..surname = "admin"
        ..email = "admin@admin.admin";
      await isar.writeTxn(() async {
        await isar.admins.put(admin);
      });
    }
    return;
  }

  Future<void> putAdmin(Admin admin) async {
    final password = admin.password;
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    admin.password = hashedPassword;
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

  Future<Admin?> validateAuth(String login, String password) async {
    final isar = await ref.watch(isarProvider.future);
    final admin = await isar.admins.where().loginEqualTo(login).findFirst();
    if (admin != null && BCrypt.checkpw(password, admin.password)) {
      return admin;
    }
    return null;
  }
}
