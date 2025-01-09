import "package:flutter/material.dart";

class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Potwierdzenie usunięcia"),
      content: Text("Czy na pewno chcesz usunąć $itemName?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Anuluj"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("Usuń"),
        ),
      ],
    );
  }
}
