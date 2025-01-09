import "dart:io";

import "package:csv/csv.dart";
import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:file_picker/file_picker.dart";

import "../../../database/models.dart";

typedef ShowMessageFunction = void Function(String message);

class CsvUtils {
  static Future<void> exportLogs(
    IList<Logs> logs,
    ShowMessageFunction showMessageFunction,
  ) async {
    try {
      final headers = [
        "Log ID",
        "Timestamp",
        "User Name",
        "Zone Number",
        "Successful Entry",
      ];
      final data = logs.map((log) {
        return [
          log.id,
          log.timestamp.toIso8601String(),
          log.user.value?.name ?? "brak",
          log.zone.value?.number ?? "brak",
          if (log.successful) "Yes" else "No",
        ];
      }).toIList();

      final csv = const ListToCsvConverter().convert([headers, ...data]);

      final String? outputFilePath = await FilePicker.platform.saveFile(
        dialogTitle: "Choose location and name for the CSV file",
        fileName: "logs_export.csv",
      );

      if (outputFilePath != null) {
        final file = File(outputFilePath);
        await file.writeAsString(csv);

        showMessageFunction("Exported to $outputFilePath");
      } else {
        showMessageFunction("Export canceled");
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      showMessageFunction("Error exporting: $e");
    }
  }
}
