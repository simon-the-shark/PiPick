// logs_list_page.dart
import "dart:io";

import "package:csv/csv.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "./database/models.dart";
import "./providers.dart";

class LogsListPage extends HookConsumerWidget {
  const LogsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAscending = useState<bool>(true);
    final selectedZone = useState<AccessZone?>(null);
    final showFailed = useState<bool>(false);

    final logsAsyncValue = ref.watch(allLogsProvider);
    final zonesAsyncValue = ref.watch(accessZonesProvider);

    Future<void> exportToCSV(List<Logs> logs) async {
      try {
        final headers = [
          "Log ID",
          "Timestamp",
          "User Name",
          "Zone Number",
          "Successful Entry"
        ];
        final data = logs.map((log) {
          return [
            log.id,
            log.timestamp.toIso8601String(),
            log.user.value?.name ?? "brak",
            log.zone.value?.number ?? "brak",
            if (log.successful) "Yes" else "No",
          ];
        }).toList();

        final csv = const ListToCsvConverter().convert([headers, ...data]);

        final String? outputFilePath = await FilePicker.platform.saveFile(
          dialogTitle: "Choose location and name for the CSV file",
          fileName: "logs_export.csv",
        );

        if (outputFilePath != null) {
          final file = File(outputFilePath);
          await file.writeAsString(csv);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Exported to $outputFilePath")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Export canceled")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error exporting: $e")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historia wejść/wyjść"),
        actions: [
          // Sorting Button (UI only, no functionality)
          IconButton(
            icon: Icon(
                isAscending.value ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: "Sort by Date",
            onPressed: () {
              // Functionality not implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Sort functionality not implemented")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              logsAsyncValue.when(
                data: (logs) async {
                  if (logs.isNotEmpty) {
                    await exportToCSV(logs);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No logs to export")),
                    );
                  }
                },
                loading: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logs are still loading")),
                  );
                },
                error: (e, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error loading logs: $e")),
                  );
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: zonesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (zones) {
                if (zones.isEmpty) {
                  return const Center(child: Text("No Zones Available"));
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Filter by Zone: "),
                    DropdownButton<AccessZone>(
                      value: selectedZone.value,
                      hint: const Text("All Zones"),
                      items: [
                        const DropdownMenuItem<AccessZone>(
                          value: null,
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
                              content:
                                  Text("Filter functionality not implemented")),
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
                                      "Failed entries filter not implemented")),
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
          ),
        ),
      ),
      body: logsAsyncValue.when(
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
