import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../business/csv_export.dart";
import "../data/all_logs_repository.dart";

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
              (message) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              ),
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No logs to export")),
          );
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
