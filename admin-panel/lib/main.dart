import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:toastification/toastification.dart";

import "router.dart";
import "theme.dart";

Future<void> main() async {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: "PiPick",
        theme: getTheme(),
        routerConfig: ref.watch(routerProvider).config(),
      ),
    );
  }
}
