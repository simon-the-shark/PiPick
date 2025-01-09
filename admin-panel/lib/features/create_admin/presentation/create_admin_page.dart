import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "admin_form.dart";

@RoutePage()
class CreateAdminPage extends StatelessWidget {
  const CreateAdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Admin"),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AdminFormDialog(),
          ),
        ),
      ),
    );
  }
}
