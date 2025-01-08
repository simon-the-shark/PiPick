import "package:flutter/material.dart";

import "../../../database/models.dart";

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {},
                icon: const Icon(Icons.incomplete_circle_sharp),
                label: Text(user.allowedZones.length.toString()),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
