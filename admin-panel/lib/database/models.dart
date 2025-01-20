import "package:isar/isar.dart";

part "models.g.dart";

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  late String surname;

  @Index(unique: true)
  late String phone;

  @Index(unique: true)
  String? rfidCard;

  final createdBy = IsarLink<Admin>();

  final allowedZones = IsarLinks<AccessZone>();

  @Backlink(to: "user")
  final logi = IsarLinks<Logs>();
}

@collection
class Admin {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String login;

  late String password;
  late String name;
  late String surname;

  @Index(unique: true)
  late String email;

  @Backlink(to: "createdBy")
  final usersCreated = IsarLinks<User>();
}

@collection
class AccessZone {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int number;

  late String location;

  @Backlink(to: "allowedZones")
  final zoneAllowedUsers = IsarLinks<User>();

  @Backlink(to: "zone")
  final logs = IsarLinks<Logs>();
}

@collection
class Logs {
  Id id = Isar.autoIncrement;

  final user = IsarLink<User>();

  final zone = IsarLink<AccessZone>();

  @Index()
  late DateTime timestamp;

  late bool successful;
  String? rfidCard;
}
