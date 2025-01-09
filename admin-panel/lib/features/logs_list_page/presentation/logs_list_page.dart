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
  const LogsListPage({
    super.key,
    this.initialFilterByZone,
  });
  final AccessZone? initialFilterByZone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = useState<AccessZone?>(initialFilterByZone);

    final allLogs = ref.watch(
      selectedZone.value != null
          ? logsByZoneRepositoryProvider(selectedZone.value!.id)
          : allLogsRepositoryProvider,
    );

    final isAscending = useState<bool>(true);
    final showFailed = useState<bool>(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          initialFilterByZone == null
              ? "Cała historia wejść/wyjść"
              : "Historia wejść/wyjść dla strefy ${initialFilterByZone!.number}: ${initialFilterByZone!.location}",
        ),
        actions: [
          SortingButton(isAscending: isAscending),
          const DownloadButton(),
        ],
        bottom: Toolbar(
          showZoneFilter: initialFilterByZone == null,
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
