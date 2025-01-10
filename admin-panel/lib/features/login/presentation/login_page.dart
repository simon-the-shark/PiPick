import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "../../../router.gr.dart";
import "widgets/custom_button.dart";

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Strona logowania"),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nazwa użytkownika",
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Hasło",
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                CustomButton(
                  text: "Zaloguj",
                  route: [HomeRoute()],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
