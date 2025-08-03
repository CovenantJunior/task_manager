import 'package:isar/isar.dart';

// Generate collection file by running `dart run build_runner build`
part 'todo_user.g.dart';

@Collection()
class TodoUser {
  Id id = 1;
  String? username;
  String? email;
  String? passwordHash;
  DateTime? lastLogin;
  DateTime? expires;
  DateTime createdAt = DateTime.now();
}