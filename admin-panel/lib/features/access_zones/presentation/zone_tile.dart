import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../database/models.dart";
import "../../../router.gr.dart";
import "../../../widgets/delete_confirmation.dart";
import "../data/acces_zones_repository.dart";
import "zone_form.dart";

class ZoneTile extends ConsumerWidget {
  final AccessZone zone;

  const ZoneTile({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onEdit() async {
      await showDialog(
        context: context,
        builder: (context) => ZoneFormDialog(initialData: zone),
      );
    }

    Future<void> onDelete() async {
      final confirm = await showDialog(
        context: context,
        builder: (context) =>
            DeleteConfirmationDialog(itemName: "strefę ${zone.number}"),
      );
      if (confirm ?? false) {
        await ref
            .read(accessZonesRepositoryProvider.notifier)
            .deleteZone(zone.id);
      }
    }

    Future<void> onDashboardNavigate() async {
      unawaited(
        context.router.push(
          DashboardRoute(accessZone: zone),
        ),
      );
    }

    Future<void> onLogsListNavigate() async {
      unawaited(
        context.router.push(
          LogsListRoute(initialFilterByZone: zone),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text("Strefa(${zone.number}): ${zone.location}"),
        subtitle: Text(
          "Liczba użytkowników z dostępem: ${zone.zoneAllowedUsers.length}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: "Logi strefy",
              child: IconButton(
                onPressed: onLogsListNavigate,
                icon: const Icon(Icons.list),
              ),
            ),
            Tooltip(
              message: "Wykresy strefy",
              child: IconButton(
                onPressed: onDashboardNavigate,
                icon: const Icon(Icons.bar_chart),
              ),
            ),
            Tooltip(
              message: "Edytuj strefę",
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ),
            Tooltip(
              message: "Usuń strefę",
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
