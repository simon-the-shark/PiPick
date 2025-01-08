import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "acces_zones_repository.dart";
import "database/models.dart";
import "features/dashboard_page/dashboard_page.dart";

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
    // return MaterialApp(
    //   title: "PiPick",
    //   theme: ThemeData(primarySwatch: Colors.blue),
    //   home: const LogsListPage(),
    // );
    return MaterialApp(
      title: "PiPick",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer(
        builder: (context, ref, _) {
          final accessZone = ref.watch(exampleAccessZoneRepositoryProvider);
          return switch (accessZone) {
            AsyncData(:final AccessZone value) =>
              DashboardPage(accessZone: value),
            AsyncError(:final error) => Text("Error: $error"),
            final _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}
