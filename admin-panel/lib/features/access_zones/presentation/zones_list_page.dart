import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../database/models.dart";
import "../data/acces_zones_repository.dart";
import "zone_form.dart";
import "zone_tile.dart";

@RoutePage()
class AccessZonesListPage extends StatelessWidget {
  const AccessZonesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Strefy dostępu")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const ZoneFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: const _ZonesDataList(),
    );
  }
}

class _ZonesDataList extends ConsumerWidget {
  const _ZonesDataList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(accessZonesRepositoryProvider);

    return switch (zones) {
      AsyncData(value: final List<AccessZone> zones) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: zones.length,
          itemBuilder: (context, index) {
            return ZoneTile(zone: zones[index]);
          },
        ),
      AsyncError(:final error) => Center(
          child: Text("Error: $error"),
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
