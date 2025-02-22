import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";

class NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final PageRouteInfo<dynamic> route;

  const NavCard({
    required this.icon,
    required this.label,
    required this.route,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          unawaited(context.router.push(route));
        },
        child: Center(
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
