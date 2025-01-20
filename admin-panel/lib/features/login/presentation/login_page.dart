import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../../../mqtt_client.dart";
import "../../../router.gr.dart";

@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipState = useState("");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Strona logowania"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Nazwa użytkownika",
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Hasło",
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => ipState.value = value,
                  decoration: const InputDecoration(
                    labelText: "Adres IP brokera MQTT",
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    ref.read(mqttHostProvider.notifier).setIp(ipState.value);
                    await context.router.replaceAll([const HomeRoute()]);
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
