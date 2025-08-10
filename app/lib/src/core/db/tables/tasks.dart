import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get id => text()();

  TextColumn get parentId =>
      text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();

  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get priority =>
      text().withDefault(const Constant('low'))();

  TextColumn get taskType =>
      text().withDefault(const Constant('simple'))();

  DateTimeColumn get deadline => dateTime().nullable()();

  IntColumn get color => integer().nullable()();

  DateTimeColumn get reminderTime => dateTime().nullable()();

  TextColumn get status => text()
      .withDefault(const Constant('pending'))();  

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Objectives extends Table {
  TextColumn get id => text()();

  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  IntColumn get weight =>
      integer()();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(task_id, name)'];
}