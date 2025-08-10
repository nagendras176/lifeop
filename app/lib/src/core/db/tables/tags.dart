import 'package:drift/drift.dart';
import 'tasks.dart';

class Tag extends Table {
  TextColumn get taskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {taskId, name};
}
