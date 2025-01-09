import "package:flutter/material.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";

import "../../../database/models.dart";
import "add_user_button.dart";
import "zone_form.dart";

class AllowedUsersSubform extends StatelessWidget {
  const AllowedUsersSubform({super.key, required this.formModel});
  final ZoneFormForm formModel;
  @override
  Widget build(BuildContext context) {
    VoidCallback onRemove(AbstractControl<User> control) {
      return () {
        formModel.allowedUsersControl.remove(control);
      };
    }

    return ReactiveFormArray(
      formArray: formModel.allowedUsersControl,
      builder: (context, formArray, child) {
        final formControls = formArray.controls.where(
          (control) => control.value != null,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(
              "Dopuszczeni użytkownicy",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final control in formControls)
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(
                    "${control.value!.name} ${control.value!.surname}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: Tooltip(
                    message: "Usuń przypisanie użytkownika",
                    child: IconButton(
                      onPressed: onRemove(control),
                      icon: const Icon(Icons.remove),
                    ),
                  ),
                ),
              ),
            if (formControls.isEmpty)
              Text(
                "Brak dopuszczonych użytkowników",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            AddUserButton(formModel),
          ],
        );
      },
    );
  }
}
