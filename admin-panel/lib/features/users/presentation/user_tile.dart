import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../database/models.dart";
import "../../../widgets/delete_confirmation.dart";
import "../data/users_repository.dart";
import "user_form.dart";

class UserTile extends ConsumerWidget {
  final User user;

  const UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onEdit() async {
      await showDialog(
        context: context,
        builder: (context) => UserFormDialog(initialData: user),
      );
    }

    Future<void> onDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => DeleteConfirmationDialog(
          itemName: "Użytkownika: ${user.name} ${user.surname}",
        ),
      );
      if (confirm ?? false) {
        await ref.read(usersRepositoryProvider.notifier).deleteUser(user.id);
      }
    }

    return Card(
      child: ListTile(
        title: Text("${user.name} ${user.surname}"),
        subtitle: Text(user.phone),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            if (user.rfidCard != null)
              Tooltip(
                message: user.rfidCard,
                child: IconButton(
                  icon: const Icon(Icons.credit_card_sharp),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {},
                ),
              )
            else
              const Tooltip(
                message: "Brak karty RFID",
                child: IconButton(
                  icon: Icon(Icons.credit_card_off_sharp),
                  onPressed: null,
                ),
              ),
            Tooltip(
              message:
                  "Liczba dozwolonych stref dostępu: ${user.allowedZones.length}",
              child: TextButton.icon(
                onPressed: null,
                icon: const Icon(Icons.incomplete_circle_sharp),
                label: Text(
                  user.allowedZones.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: "Edytuj użytkownika",
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ),
            Tooltip(
              message: "Usuń użytkownika",
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
