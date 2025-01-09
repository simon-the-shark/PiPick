import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:toastification/toastification.dart";

import "../business/csv_export.dart";
import "../data/logs_repository.dart";

class DownloadButton extends ConsumerWidget {
  const DownloadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogs = ref.watch(allLogsRepositoryProvider);

    return allLogs.when(
      data: (logs) => IconButton(
        icon: const Icon(Icons.download),
        onPressed: () async {
          if (logs.isNotEmpty) {
            return CsvUtils.exportLogs(
              logs,
              (message) => toastification.show(
                title: Text(message),
                autoCloseDuration: const Duration(seconds: 3),
              ),
            );
          }
          toastification.show(
            title: const Text("No logs to export"),
            autoCloseDuration: const Duration(seconds: 3),
          );
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
