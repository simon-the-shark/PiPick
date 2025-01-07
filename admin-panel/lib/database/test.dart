import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

import "models.dart";

Future<void> main() async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [UserSchema, AdminSchema, AccessZoneSchema, LogsSchema],
    directory: dir.path,
  );

  await isar.writeTxn(() async {
    // Tworzenie Admina
    final admin = Admin()
      ..login = "admin123"
      ..password = "securepassword"
      ..name = "Jan"
      ..surname = "Kowalski"
      ..email = "jan.kowalski@example.com";

    await isar.admins.put(admin);

    final user = User()
      ..name = "Anna"
      ..surname = "Nowak"
      ..phone = "123-456-789"
      ..rfidCard = "RFID123456";

    user.admin.value = admin;
    admin.users.add(user);

    await isar.users.put(user);
    await admin.users.save();

    final strefa = AccessZone()
      ..number = 1
      ..location = "Wejście testowe";

    await isar.accessZones.put(strefa);

    user.zones.add(strefa);
    strefa.users.add(user);

    await user.zones.save();
    await strefa.users.save();

    final log = Logs()
      ..timestamp = DateTime.now()
      ..successful = false
      ..rfidCard = "RFID123456";

    log.user.value = user;
    log.zone.value = strefa;

    await isar.logs.put(log);
    await log.user.save();
    await log.zone.save();

    final log2 = Logs()
      ..timestamp = DateTime(2024, 12, 28)
      ..successful = false
      ..rfidCard = "RFID123";

    log2.user.value = user;
    log2.zone.value = strefa;

    await isar.logs.put(log2);
    await log2.user.save();
    await log2.zone.save();

    final log3 = Logs()
      ..timestamp = DateTime(2024, 12, 29)
      ..successful = false
      ..rfidCard = "RFID123";

    log3.user.value = user;
    log3.zone.value = strefa;

    await isar.logs.put(log3);
    await log3.user.save();
    await log3.zone.save();
  });

  final admins = await isar.admins.where().findAll();
  print("Admini:");
  for (final admin in admins) {
    print("ID: ${admin.id}, Login: ${admin.login}, Email: ${admin.email}");
    for (final user in admin.users) {
      print(
          "  Użytkownik: ${user.name} ${user.surname}, Telefon: ${user.phone}");
    }
  }

  final users = await isar.users.where().findAll();
  print("\nUżytkownicy:");
  for (final user in users) {
    print(
        "ID: ${user.id}, Name: ${user.name} ${user.surname}, Phone: ${user.phone}");
    final userStrefy = await user.zones;
    for (final strefa in userStrefy) {
      print(
          "  Strefa: Numer ${strefa.number}, Lokalizacja: ${strefa.location}");
    }
    final userLogi = await user.logi;
    for (final log in userLogi) {
      print("  Log: Timestamp ${log.timestamp}, Czy udane: ${log.successful}");
    }
  }

  await isar.close();
}
