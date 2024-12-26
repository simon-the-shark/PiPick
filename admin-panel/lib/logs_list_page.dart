import "dart:io";

import "package:csv/csv.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:isar/isar.dart";

import "./database/models.dart";

class LogsListPage extends StatefulWidget {
  final Isar isar;

  const LogsListPage({super.key, required this.isar});

  @override
  State<LogsListPage> createState() => _LogsListPageState();
}

class _LogsListPageState extends State<LogsListPage> {
  late Future<List<Logs>> _futureLogs;

  @override
  void initState() {
    super.initState();
    _futureLogs = _loadLogs();
  }

  Future<List<Logs>> _loadLogs() async {
    return widget.isar.logs.where().findAll();
  }

  Future<void> _exportToCSV(List<Logs> logs) async {
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
          log.timestamp,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historia wejść/wyjść"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final logs = await _futureLogs;
              if (logs.isNotEmpty) {
                await _exportToCSV(logs);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No logs to export")),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Logs>>(
        future: _futureLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Brak logów"));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text("Log ID: ${log.id} - ${log.timestamp}"),
                subtitle: Text(
                  'Użytkownik: ${log.user.value?.name ?? "brak"}\n'
                  'Strefa: ${log.zone.value?.number ?? "brak"}\n'
                  "Udane wejście: ${log.successful}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
