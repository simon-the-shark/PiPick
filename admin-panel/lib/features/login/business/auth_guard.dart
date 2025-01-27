import "package:auto_route/auto_route.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../router.gr.dart";
import "auth_service.dart";

part "auth_guard.g.dart";

class AuthGuard extends AutoRouteGuard {
  const AuthGuard(this.ref);
  final Ref ref;
  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    // the navigation is paused until resolver.next() is called with either
    // true to resume/continue navigation or false to abort navigation
    if (ref.read(authServiceProvider) != null) {
      // if user is authenticated we continue
      resolver.next();
    } else {
      // we redirect the user to our login page
      // tip: use resolver.redirect to have the redirected route
      // automatically removed from the stack when the resolver is completed
      await resolver.redirect(const RootRoute());
    }
  }
}

@riverpod
AuthGuard authGuard(Ref ref) {
  return AuthGuard(ref);
}
