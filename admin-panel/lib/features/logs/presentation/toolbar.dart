import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:toastification/toastification.dart";

import "../../../database/models.dart";
import "../../access_zones/data/acces_zones_repository.dart";

class Toolbar extends ConsumerWidget implements PreferredSizeWidget {
  const Toolbar({
    super.key,
    required this.selectedZone,
    required this.showFailed,
    this.showZoneFilter = true,
  });

  final ValueNotifier<AccessZone?> selectedZone;
  final ValueNotifier<bool> showFailed;
  final bool showZoneFilter;
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessZones = ref.watch(accessZonesRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: accessZones.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (zones) {
          if (zones.isEmpty) {
            return const Center(child: Text("No Zones Available"));
          }
          return Row(
            children: [
              if (showZoneFilter) const Text("Filter by Zone: "),
              if (showZoneFilter)
                DropdownButton<AccessZone>(
                  value: selectedZone.value,
                  hint: const Text("All Zones"),
                  items: [
                    const DropdownMenuItem<AccessZone>(
                      child: Text("All Zones"),
                    ),
                    ...zones.map((zone) {
                      return DropdownMenuItem<AccessZone>(
                        value: zone,
                        child: Text("Zone ${zone.number}"),
                      );
                    }),
                  ],
                  onChanged: (zone) {
                    selectedZone.value = zone;
                  },
                ),
              if (showZoneFilter) const SizedBox(width: 20),
              Row(
                children: [
                  Checkbox(
                    value: showFailed.value,
                    onChanged: (value) {
                      toastification.show(
                        title:
                            const Text("Failed entries filter not implemented"),
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    },
                  ),
                  const Text("Nieudane wejścia"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
