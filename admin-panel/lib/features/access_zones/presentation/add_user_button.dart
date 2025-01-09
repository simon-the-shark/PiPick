import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../database/models.dart";
import "../../users/data/users_repository.dart";
import "select_user_dialog.dart";
import "zone_form.dart";

class AddUserButton extends ConsumerWidget {
  const AddUserButton(this.formModel, {super.key});
  final ZoneFormForm formModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> addUser() async {
      final users = await ref.read(usersRepositoryProvider.future);
      final alreadySelected =
          formModel.allowedUsersControl.value?.whereType<User>().toList() ?? [];
      if (!context.mounted) return;
      final user = await showDialog(
        context: context,
        builder: (context) =>
            SelectUserDialog(users: users, alreadySelected: alreadySelected),
      );
      if (user != null) {
        formModel.addAllowedUsersItem(user);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: addUser,
        child: const Text("Przypisz użytkownika"),
      ),
    );
  }
}
