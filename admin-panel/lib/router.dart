import "package:auto_route/auto_route.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "router.gr.dart";

part "router.g.dart";

@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: "/",
          page: LoginRoute.page,
        ),
        AutoRoute(
          path: "/home",
          page: HomeRoute.page,
        ),
        AutoRoute(
          path: "/zones",
          page: AccessZonesListRoute.page,
        ),
        AutoRoute(
          path: "/users",
          page: UsersListRoute.page,
        ),
        AutoRoute(
          path: "/logs",
          page: LogsListRoute.page,
        ),
        AutoRoute(
          path: "/dashboard",
          page: DashboardRoute.page,
        ),
        AutoRoute(
          path: "/admin",
          page: CreateAdminRoute.page,
        ),
      ];
}

@Riverpod(keepAlive: true)
AppRouter router(Ref ref) {
  return AppRouter();
}
