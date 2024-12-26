import "package:isar/isar.dart";
part "models.g.dart";

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  late String surname;
  late String phone;
  String? rfidCard;

  final admin = IsarLink<Admin>();

  final zones = IsarLinks<AccessZone>();

  @Backlink(to: 'user')
  final logi = IsarLinks<Logs>();
}

@collection
class Admin {
  Id id = Isar.autoIncrement;

  late String login;
  late String password;
  late String name;
  late String surname;
  late String email;

  @Backlink(to: 'admin')
  final users = IsarLinks<User>();
}

@collection
class AccessZone {
  Id id = Isar.autoIncrement;

  late int number;
  late String location;

  @Backlink(to: 'zones')
  final users = IsarLinks<User>();

  @Backlink(to: 'zone')
  final logs = IsarLinks<Logs>();
}

@collection
class Logs {
  Id id = Isar.autoIncrement;

  final user = IsarLink<User>();

  final zone = IsarLink<AccessZone>();

  late DateTime timestamp;
  late bool successful;
  String? rfidCard;
}
