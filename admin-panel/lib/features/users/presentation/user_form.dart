import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";

import "../../../database/models.dart";
import "../data/users_repository.dart";

part "user_form.freezed.dart";
part "user_form.gform.dart";

@Rf()
@freezed
class UserForm with _$UserForm {
  factory UserForm({
    @RfControl(
      validators: [RequiredValidator()],
    )
    required String name,
    @RfControl(
      validators: [RequiredValidator()],
    )
    required String surname,
    @RfControl(
      validators: [RequiredValidator()],
    )
    required String phone,
    @RfControl() String? rfidCard,
  }) = _UserForm;
}

class UserFormDialog extends ConsumerWidget {
  const UserFormDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UserFormFormBuilder(
      model: UserForm(
        name: "",
        surname: "",
        phone: "",
      ),
      builder: (context, formModel, child) {
        Future<void> onSubmit() async {
          formModel.form.markAllAsTouched();
          if (formModel.form.valid) {
            unawaited(
              ref.read(usersRepositoryProvider.notifier).addUser(
                    User()
                      ..name = formModel.nameControl.value!
                      ..surname = formModel.surnameControl.value!
                      ..phone = formModel.phoneControl.value!
                      ..rfidCard = formModel.rfidCardControl?.value == ""
                          ? null
                          : formModel.rfidCardControl?.value,
                  ),
            );
            Navigator.of(context).pop();
          }
        }

        void onCancel() {
          Navigator.of(context).pop();
        }

        return AlertDialog(
          title: const Text("Add User"),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReactiveTextField<String>(
                  formControl: formModel.nameControl,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        "Imię nie może być puste",
                  },
                  decoration: const InputDecoration(labelText: "Imię"),
                  keyboardType: TextInputType.name,
                ),
                ReactiveTextField<String>(
                  formControl: formModel.surnameControl,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        "Nazwisko nie może być puste",
                  },
                  decoration: const InputDecoration(labelText: "Nazwisko"),
                  keyboardType: TextInputType.name,
                ),
                ReactiveTextField<String>(
                  formControl: formModel.phoneControl,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        "Telefon nie może być pusty",
                  },
                  decoration: const InputDecoration(labelText: "Telefon"),
                  keyboardType: TextInputType.phone,
                ),
                ReactiveTextField<String>(
                  formControl: formModel.rfidCardControl,
                  decoration: const InputDecoration(labelText: "Karta RFID"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: onCancel,
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: onSubmit,
              child: const Text("Zapisz"),
            ),
          ],
        );
      },
    );
  }
}
