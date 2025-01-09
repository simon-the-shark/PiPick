import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../database/models.dart";
import "../data/users_repository.dart";
import "user_form.dart";
import "user_tile.dart";

@RoutePage()
class UsersListPage extends ConsumerWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zarządaj użytkownikami")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const UserFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: const _UsersDataList(),
    );
  }
}

class _UsersDataList extends ConsumerWidget {
  const _UsersDataList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersRepositoryProvider);

    return switch (users) {
      AsyncData(value: final List<User> users) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return UserTile(user: users[index]);
          },
        ),
      AsyncError(:final error) => Center(
          child: Text("Error: $error"),
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
