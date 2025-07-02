import 'package:hive/hive.dart';

part 'todo.g.dart';
@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  String category; // ✅ Required non-null field

  Todo({
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.category = 'General', // ✅ Provide default
  });
}