import 'package:drift/drift.dart';
import 'tasks.dart';

class TaskLinks extends Table {
  @ReferenceName('outgoingLinks')
  TextColumn get fromTaskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  
  @ReferenceName('incomingLinks')
  TextColumn get toTaskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {fromTaskId, toTaskId};
}