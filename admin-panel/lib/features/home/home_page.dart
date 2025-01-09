import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";

import "../../router.gr.dart";
import "nav_card.dart";

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PiPick"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 4,
        padding: const EdgeInsets.all(16),
        children: [
          const NavCard(
            icon: Icons.map,
            label: "Strefy dostępu",
            route: AccessZonesListRoute(),
          ),
          const NavCard(
            icon: Icons.people,
            label: "Użytkownicy",
            route: UsersListRoute(),
          ),
          NavCard(
            icon: Icons.access_time,
            label: "Wszystkie Logi",
            route: LogsListRoute(),
          ),
          const NavCard(
            icon: Icons.admin_panel_settings,
            label: "Dodaj Admina",
            route: CreateAdminRoute(),
          ),
        ],
      ),
    );
  }
}
