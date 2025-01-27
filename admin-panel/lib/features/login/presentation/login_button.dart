import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:toastification/toastification.dart";

import "../../../mqtt_client.dart";
import "../../../router.gr.dart";
import "../../create_admin/data/admin_repository.dart";
import "login_page.dart";

class LoginButton extends ConsumerWidget {
  const LoginButton(this.formModel, {super.key});
  final LoginFormForm formModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final repo = ref.read(adminRepositoryProvider.notifier);
        if (formModel.form.valid &&
            formModel.ipNumberControl.value != null &&
            await repo.validateAuth(
              formModel.loginControl.value!,
              formModel.passwordControl.value!,
            )) {
          ref.read(adminRepositoryProvider.notifier);
          ref.read(mqttHostProvider.notifier).setIp(
                formModel.ipNumberControl.value!,
              );
          if (context.mounted) {
            await context.router.replaceAll([const HomeRoute()]);
          }
        } else {
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
