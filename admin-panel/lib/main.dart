import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "features/users/presentation/users_list_page.dart";
import "theme.dart";

Future<void> main() async {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PiPick",
      theme: getTheme(),
      home: const UsersListPage(),
    );
    // return MaterialApp(
    //   title: "PiPick",
    //   theme: ThemeData(primarySwatch: Colors.blue),
    //   home: Consumer(
    //     builder: (context, ref, _) {
    //       final accessZone = ref.watch(exampleAccessZoneRepositoryProvider);
    //       return switch (accessZone) {
    //         AsyncData(:final AccessZone value) =>
    //           DashboardPage(accessZone: value),
    //         AsyncError(:final error) => Text("Error: $error"),
    //         final _ => const Center(child: CircularProgressIndicator()),
    //       };
    //     },
    //   ),
    // );
  }
}
