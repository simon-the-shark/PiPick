import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../home/home_page.dart";
import "../business/auth_service.dart";
import "login_page.dart";

@RoutePage()
class RootPage extends ConsumerWidget {
  const RootPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    return auth == null ? const LoginPage() : const HomePage();
  }
}
