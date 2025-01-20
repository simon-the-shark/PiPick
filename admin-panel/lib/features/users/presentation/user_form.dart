import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:isar/isar.dart";
import "package:mqtt_client/mqtt_client.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";

import "../../../database/models.dart";
import "../../../database/provider.dart";
import "../../../mqtt_client.dart";
import "../../../utils/unique_db_form_validator.dart";
import "../../access_zones/data/acces_zones_repository.dart";
import "../data/users_repository.dart";
import "rfid_field.dart";

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
  const UserFormDialog({
    super.key,
    this.initialData,
  });

  final User? initialData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UserFormFormBuilder(
      initState: (context, formModel) {
        formModel.phoneControl.setAsyncValidators([
          UniqueDbFormValidator(
            (phone) async {
              return ref
                  .read(usersRepositoryProvider.notifier)
                  .isPhoneUnique(phone);
            },
          ),
        ]);
      },
      model: UserForm(
        name: initialData?.name ?? "",
        surname: initialData?.surname ?? "",
        phone: initialData?.phone ?? "",
        rfidCard: initialData?.rfidCard,
      ),
      builder: (context, formModel, child) {
        Future<void> onSubmit() async {
          formModel.form.markAllAsTouched();
          if (formModel.form.valid) {
            unawaited(
              ref.read(usersRepositoryProvider.notifier).putUser(
                    User()
                      ..id = initialData?.id ?? Isar.autoIncrement
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
          title: Text(
            initialData == null ? "Dodaj użytkownika" : "Edytuj użytkownika",
          ),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 18,
              children: [
                ReactiveTextField<String>(
                  formControl: formModel.nameControl,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        "Imię nie może być puste",
                  },
                  decoration: const InputDecoration(
                    labelText: "Imię",
                    hintText: "np. Jan",
                  ),
                  keyboardType: TextInputType.name,
                ),
                ReactiveTextField<String>(
                  formControl: formModel.surnameControl,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        "Nazwisko nie może być puste",
                  },
                  decoration: const InputDecoration(
                    labelText: "Nazwisko",
                    hintText: "np. Kowalski",
                  ),
                  keyboardType: TextInputType.name,
                ),
                ReactiveTextField<String>(
                  formControl: formModel.phoneControl,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        "Telefon nie może być pusty",
                    MyValidationMessage.unique: (_) =>
                        "Telefon musi być unikalny",
                  },
                  decoration: const InputDecoration(
                    labelText: "Telefon",
                    hintText: "np. 123456789",
                  ),
                  keyboardType: TextInputType.phone,
                ),
                ref.watch(accessZonesRepositoryProvider).when(
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text("Error: $error"),
                      data: (zones) => RfidField(
                        rfidCardControl: formModel.rfidCardControl,
                        zones: zones,
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: onCancel,
              child: const Text("Anuluj"),
            ),
            SubmitButton(onSubmit: onSubmit),
          ],
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ReactiveUserFormFormConsumer(
      builder: (context, formModel, child) {
        return ElevatedButton(
          onPressed: formModel.form.valid ? onSubmit : null,
          child: const Text("Zapisz"),
        );
      },
    );
  }
}
