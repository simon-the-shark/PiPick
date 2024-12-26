import "package:flutter/material.dart";
import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

import "./database/models.dart";
import "dashboard_page.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [UserSchema, AdminSchema, AccessZoneSchema, LogsSchema],
    directory: dir.path,
  );

  AccessZone? zone = await isar.accessZones.get(2);

  print(zone?.id);
  print(zone?.number);
  print(zone?.location);

  if (zone == null) {
    zone = AccessZone()
      ..number = 10
      ..location = "Domyślna Lokalizacja";

    await isar.writeTxn(() async {
      await isar.accessZones.put(zone!);
    });
  }

  runApp(MyApp(isar: isar, zone: zone));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  final AccessZone zone;

  const MyApp({Key? key, required this.isar, required this.zone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Logs App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardPage(isar: isar, zone: zone),
    );
  }
}
