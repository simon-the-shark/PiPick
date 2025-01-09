// logs_list_page.dart
import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../database/models.dart";
import "../data/all_logs_repository.dart";
import "download_button.dart";
import "sorting_button.dart";
import "toolbar.dart";

@RoutePage()
class LogsListPage extends HookConsumerWidget {
  const LogsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogs = ref.watch(allLogsRepositoryProvider);

    final isAscending = useState<bool>(true);
    final selectedZone = useState<AccessZone?>(null);
    final showFailed = useState<bool>(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historia wejść/wyjść"),
        actions: [
          SortingButton(isAscending: isAscending),
          const DownloadButton(),
        ],
        bottom: Toolbar(
          selectedZone: selectedZone,
          showFailed: showFailed,
        ),
      ),
      body: allLogs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Błąd: $e")),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text("Brak logów"));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text("Log ID: ${log.id} - ${log.timestamp}"),
                subtitle: Text(
                  'Użytkownik: ${log.user.value?.name ?? "brak"}\n'
                  'Strefa: ${log.zone.value?.number ?? "brak"}\n'
                  "Udane wejście: ${log.successful ? "Yes" : "No"}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
