import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../database/models.dart";
import "../../access_zones/data/acces_zones_repository.dart";

class Toolbar extends ConsumerWidget implements PreferredSizeWidget {
  const Toolbar({
    super.key,
    required this.selectedZone,
    required this.showFailed,
  });

  final ValueNotifier<AccessZone?> selectedZone;
  final ValueNotifier<bool> showFailed;

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
              const Text("Filter by Zone: "),
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
                  // Functionality not implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Filter functionality not implemented"),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Checkbox(
                    value: showFailed.value,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Failed entries filter not implemented",
                          ),
                        ),
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
