import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:isar/isar.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";
import "package:toastification/toastification.dart";

import "../../../database/models.dart";
import "../../../utils/equal_db_form_validator.dart";
import "../../../utils/unique_db_form_validator.dart";
import "../data/admin_repository.dart";

part "admin_form.freezed.dart";
part "admin_form.gform.dart";

@Rf()
@freezed
class AdminForm with _$AdminForm {
  factory AdminForm({
    @RfControl(
      validators: [
        RequiredValidator(),
        MinLengthValidator(6),
      ],
    )
    required String password,
    @RfControl(
      validators: [
        RequiredValidator(),
      ],
    )
    required String repeatPassword,
    @RfControl(
      validators: [
        RequiredValidator(),
        EmailValidator(),
      ],
    )
    required String email,
    @RfControl(
      validators: [
        RequiredValidator(),
      ],
    )
    required String login,
    @RfControl(
      validators: [RequiredValidator()],
    )
    required String name,
    @RfControl(
      validators: [RequiredValidator()],
    )
    required String surname,
  }) = _AdminForm;
}

class AdminFormDialog extends ConsumerWidget {
  const AdminFormDialog({
    super.key,
    this.initialData,
  });

  final Admin? initialData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminFormFormBuilder(
      initState: (context, formModel) {
        formModel.loginControl.setAsyncValidators([
          UniqueDbFormValidator(
            (login) async {
              return ref
                  .read(adminRepositoryProvider.notifier)
                  .isLoginUnique(login);
            },
          ),
        ]);
        formModel.emailControl.setAsyncValidators([
          UniqueDbFormValidator(
            (email) async {
              return ref
                  .read(adminRepositoryProvider.notifier)
                  .isEmailUnique(email);
            },
          ),
        ]);
        formModel.repeatPasswordControl.setValidators([
          EqualAsOtherFormValidator(formModel.passwordControl),
        ]);
      },
      model: AdminForm(
        login: initialData?.login ?? "",
        password: "",
        repeatPassword: "",
        email: initialData?.email ?? "",
        name: initialData?.name ?? "",
        surname: initialData?.surname ?? "",
      ),
      builder: (context, formModel, child) {
        return _FormContent(
          formModel: formModel,
          initialData: initialData,
        );
      },
    );
  }
}

class _FormContent extends ConsumerWidget {
  const _FormContent({
    required this.formModel,
    required this.initialData,
  });

  final AdminFormForm formModel;
  final Admin? initialData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onSubmit() async {
      formModel.form.markAllAsTouched();
      if (formModel.form.valid) {
        final adminRepository = ref.read(adminRepositoryProvider.notifier);
        final admin = Admin()
          ..id = initialData?.id ?? Isar.autoIncrement
          ..login = formModel.loginControl.value!
          ..password = formModel.passwordControl.value!
          ..email = formModel.emailControl.value!
          ..name = formModel.nameControl.value!
          ..surname = formModel.surnameControl.value!;

        await adminRepository.putAdmin(admin);
        toastification.show(
          title: const Text("Pomyślnie dodano administratora."),
          autoCloseDuration: const Duration(seconds: 3),
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    void onCancel() {
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: Text(
        initialData == null ? "Dodaj administratora" : "Edytuj administratora",
      ),
      scrollable: true,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReactiveTextField<String>(
              formControl: formModel.loginControl,
              validationMessages: {
                ValidationMessage.required: (_) => "Login nie może być pusty",
                MyValidationMessage.unique: (_) => "Login musi być unikalny",
              },
              decoration: const InputDecoration(
                labelText: "Login",
                hintText: "np. admin123",
              ),
            ),
            const SizedBox(height: 16),
            ReactiveTextField<String>(
              formControl: formModel.passwordControl,
              validationMessages: {
                ValidationMessage.required: (_) => "Hasło nie może być puste",
                ValidationMessage.minLength: (error) =>
                    "Hasło musi mieć co najmniej 6 znaków",
              },
              decoration: const InputDecoration(
                labelText: "Hasło",
                hintText: "Wprowadź hasło",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ReactiveTextField<String>(
              formControl: formModel.repeatPasswordControl,
              validationMessages: {
                ValidationMessage.required: (_) => "Należy powtórzyć hasło",
                NotEqualValidationMessage.notEqual: (_) =>
                    "Hasła muszą być takie same",
              },
              decoration: const InputDecoration(
                labelText: "Powtórz hasło",
                hintText: "Powtórz hasło",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ReactiveTextField<String>(
              formControl: formModel.emailControl,
              validationMessages: {
                ValidationMessage.required: (_) => "Email nie może być pusty",
                ValidationMessage.email: (_) => "Nieprawidłowy format email",
                MyValidationMessage.unique: (_) => "Email musi być unikalny",
              },
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "np. admin@example.com",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ReactiveTextField<String>(
              formControl: formModel.nameControl,
              validationMessages: {
                ValidationMessage.required: (_) => "Imię nie może być puste",
              },
              decoration: const InputDecoration(
                labelText: "Imię",
                hintText: "np. Jan",
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
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
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ReactiveAdminFormFormConsumer(
      builder: (context, formModel, child) {
        return ElevatedButton(
          onPressed: formModel.form.valid ? onSubmit : null,
          child: const Text("Zapisz"),
        );
      },
    );
  }
}
