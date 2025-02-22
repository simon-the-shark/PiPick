// ignore_for_file: avoid_print

import "package:bcrypt/bcrypt.dart";
import "package:flutter/material.dart";
import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

import "models.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [UserSchema, AdminSchema, AccessZoneSchema, LogsSchema],
    directory: dir.path,
  );

  await isar.writeTxn(() async {
    final admin = Admin()
      ..login = "admin123"
      ..password = BCrypt.hashpw("admin123", BCrypt.gensalt())
      ..name = "Jan"
      ..surname = "Kowalski"
      ..email = "jan.kowalski@example.com";

    await isar.admins.put(admin);

    final user = User()
      ..name = "Anna"
      ..surname = "Nowak"
      ..phone = "123-456-789"
      ..rfidCard = "RFID123456";

    user.createdBy.value = admin;
    admin.usersCreated.add(user);

    await isar.users.put(user);
    await admin.usersCreated.save();

    final strefa = AccessZone()
      ..number = 1
      ..location = "Wejście testowe";

    await isar.accessZones.put(strefa);

    user.allowedZones.add(strefa);
    strefa.zoneAllowedUsers.add(user);

    await user.allowedZones.save();
    await strefa.zoneAllowedUsers.save();

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
    for (int i = 0; i < 10; i++) {
      final log = Logs()
        ..timestamp = DateTime.now().add(Duration(days: i))
        ..successful = 2 % i == 0
        ..rfidCard = "RFID${123 + i}";

      log.user.value = user;
      log.zone.value = strefa;

      await isar.logs.put(log);
      await log.user.save();
      await log.zone.save();
    }
    await isar.logs.put(log3);
    await log3.user.save();
    await log3.zone.save();
  });

  final admins = await isar.admins.where().findAll();
  print("Admini:");
  for (final admin in admins) {
    print("ID: ${admin.id}, Login: ${admin.login}, Email: ${admin.email}");
    for (final user in admin.usersCreated) {
      print(
        "  Użytkownik: ${user.name} ${user.surname}, Telefon: ${user.phone}",
      );
    }
  }

  final users = await isar.users.where().findAll();
  print("\nUżytkownicy:");
  for (final user in users) {
    print(
      "ID: ${user.id}, Name: ${user.name} ${user.surname}, Phone: ${user.phone}",
    );
    for (final strefa in user.allowedZones) {
      print(
        "  Strefa: Numer ${strefa.number}, Lokalizacja: ${strefa.location}",
      );
    }
    for (final log in user.logi) {
      print("  Log: Timestamp ${log.timestamp}, Czy udane: ${log.successful}");
    }
  }

  await isar.close();
}
