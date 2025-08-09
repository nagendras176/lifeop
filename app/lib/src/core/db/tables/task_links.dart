import 'package:drift/drift.dart';
import 'tasks.dart';

class TaskLinks extends Table {
  TextColumn get fromTaskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get toTaskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {fromTaskId, toTaskId};
}