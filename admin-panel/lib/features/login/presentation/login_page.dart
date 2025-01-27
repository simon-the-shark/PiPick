import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";

import "login_button.dart";

part "login_page.freezed.dart";
part "login_page.gform.dart";

@Rf()
@freezed
class LoginForm with _$LoginForm {
  factory LoginForm({
    @RfControl(validators: [RequiredValidator()]) required String login,
    @RfControl(validators: [RequiredValidator()]) required String password,
    @RfControl(validators: [RequiredValidator()]) required String ipNumber,
  }) = _LoginForm;
}

@RoutePage()
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LoginFormFormBuilder(
              builder: (context, formModel, child) => Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: Image.asset("assets/text_logo.png"),
                  ),
                  const SizedBox(height: 32),
                  ReactiveTextField<String>(
                    formControl: formModel.loginControl,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          "Nazwa użytkownika nie może być pusta",
                    },
                    decoration:
                        const InputDecoration(labelText: "Nazwa użytkownika"),
                  ),
                  const SizedBox(height: 16),
                  ReactiveTextField<String>(
                    formControl: formModel.passwordControl,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          "Hasło nie może być puste",
                    },
                    decoration: const InputDecoration(labelText: "Hasło"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ReactiveTextField<String>(
                    formControl: formModel.ipNumberControl,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          "Adres IP brokera MQTT nie może być pusty",
                    },
                    decoration: const InputDecoration(
                      labelText: "Adres IP brokera MQTT",
                    ),
                  ),
                  const SizedBox(height: 32),
                  LoginButton(formModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
