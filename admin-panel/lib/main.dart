// lib/main.dart

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "dashboard_page.dart";
import "providers.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessZoneAsyncValue = ref.watch(accessZoneProvider);

    return MaterialApp(
      title: "Logs App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: accessZoneAsyncValue.when(
        data: (zone) => const DashboardPage(),
        loading: () => Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
          ),
          body: const Center(child: Text("Error initializing AccessZone")),
        ),
      ),
    );
  }
}
