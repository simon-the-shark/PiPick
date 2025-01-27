import "package:auto_route/auto_route.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "features/login/business/auth_guard.dart";
import "router.gr.dart";

part "router.g.dart";

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  AppRouter(this.ref);
  final Ref ref;
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: "/",
          page: RootRoute.page,
        ),
        AutoRoute(
          guards: [ref.read(authGuardProvider)],
          path: "/zones",
          page: AccessZonesListRoute.page,
        ),
        AutoRoute(
          guards: [ref.read(authGuardProvider)],
          path: "/users",
          page: UsersListRoute.page,
        ),
        AutoRoute(
          guards: [ref.read(authGuardProvider)],
          path: "/logs",
          page: LogsListRoute.page,
        ),
        AutoRoute(
          guards: [ref.read(authGuardProvider)],
          path: "/dashboard",
          page: DashboardRoute.page,
        ),
        AutoRoute(
          guards: [ref.read(authGuardProvider)],
          path: "/admin",
          page: CreateAdminRoute.page,
        ),
      ];
}

@Riverpod(keepAlive: true)
AppRouter router(Ref ref) {
  return AppRouter(ref);
}
