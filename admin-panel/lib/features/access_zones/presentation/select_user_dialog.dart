import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:flutter/material.dart";
import "package:toastification/toastification.dart";

import "../../../database/models.dart";

class SelectUserDialog extends StatelessWidget {
  const SelectUserDialog({
    super.key,
    required this.users,
    required this.alreadySelected,
  });
  final IList<User> users;
  final IList<User> alreadySelected;
  @override
  Widget build(BuildContext context) {
    final alreadySelectedIds = alreadySelected.map((user) => user.id).toSet();
    return SimpleDialog(
      title: const Text("Dopuść użytkownika"),
      children: [
        for (final user in users)
          SimpleDialogOption(
            onPressed: alreadySelectedIds.contains(user.id)
                ? () {
                    toastification.show(
                      title: const Text("Ten użytkownik jest już dopuszczony"),
                      autoCloseDuration: const Duration(seconds: 1),
                    );
                  }
                : () {
                    Navigator.pop(context, user);
                  },
            child: Text(
              "${user.name} ${user.surname}",
              style: TextStyle(
                color: alreadySelectedIds.contains(user.id)
                    ? Theme.of(context).disabledColor
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
