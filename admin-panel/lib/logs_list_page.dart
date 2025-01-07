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
  late Future<List<AccessZone>> _futureZones;

  AccessZone? _selectedZone;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _futureLogs = _loadLogs();
    _futureZones = _loadZones();
  }

  Future<List<Logs>> _loadLogs() async {
    // Tworzymy bazowe zapytanie `where()`
    var baseQuery = widget.isar.logs.where();

    // Dodajemy sortowanie do zapytania
    var sortedQuery = _isAscending
        ? baseQuery.sortByTimestamp()
        : baseQuery.sortByTimestampDesc();

    // Pobieramy dane z finalnego zapytania
    return sortedQuery.findAll();
  }

  Future<List<AccessZone>> _loadZones() async {
    return widget.isar.accessZones.where().findAll();
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
          log.timestamp.toIso8601String(),
          log.user.value?.name ?? "brak",
          log.zone.value?.number ?? "brak",
          log.successful ? "Yes" : "No",
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
          // Sorting Button
          IconButton(
            icon:
                Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: "Sort by Date",
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
                _futureLogs = _loadLogs();
              });
            },
          ),
          // Export Button
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<AccessZone>>(
              future: _futureZones,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Zones Available"));
                }

                final zones = snapshot.data!;
                return Row(
                  children: [
                    const Text("Filter by Zone: "),
                    DropdownButton<AccessZone>(
                      value: _selectedZone,
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
                        }).toList(),
                      ],
                      onChanged: (zone) {
                        setState(() {
                          _selectedZone = zone;
                          _futureLogs = _loadLogs();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
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
