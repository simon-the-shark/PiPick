import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:toastification/toastification.dart";

import "../business/auth_service.dart";
import "login_page.dart";

class LoginButton extends ConsumerWidget {
  const LoginButton(this.formModel, {super.key});
  final LoginFormForm formModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final service = ref.read(authServiceProvider.notifier);
        if (formModel.form.valid &&
            formModel.ipNumberControl.value != null &&
            await service.login(
              formModel.loginControl.value!,
              formModel.passwordControl.value!,
              formModel.ipNumberControl.value!,
            )) {
        } else {
          formModel.form.markAllAsTouched();
          toastification.show(
            title: const Text(
              "Niepoprawne dane logowania.",
            ),
            autoCloseDuration: const Duration(seconds: 3),
            type: ToastificationType.error,
          );
        }
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
      ),
      child: const Text("Zaloguj się"),
    );
  }
}
