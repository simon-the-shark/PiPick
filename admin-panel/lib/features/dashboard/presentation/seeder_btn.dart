import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../database/models.dart";
import "../../logs/data/logs_repository.dart";

class SeederBtn extends HookConsumerWidget {
  const SeederBtn(this.zone, {super.key});
  final AccessZone zone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final onSeed = useCallback(
      () async {
        final seeder = ref.read(seederProvider);
        isLoading.value = true;
        await seeder(zone.id);
        isLoading.value = false;
        ref.invalidate(logsByZoneRepositoryProvider(zone.id));
        ref.invalidate(allLogsRepositoryProvider);
      },
      [zone.id, ref],
    );
    return TextButton.icon(
      icon: isLoading.value ? null : const Icon(Icons.data_object_sharp),
      label: isLoading.value
          ? const CircularProgressIndicator()
          : const Text("Seed"),
      onPressed: isLoading.value ? null : onSeed,
    );
  }
}
