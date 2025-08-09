import 'package:drift/drift.dart';
import 'connection/open_connection.dart';
import 'tables/tasks.dart';
import 'tables/tags.dart';
import 'tables/task_links.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tasks, Objectives, Tags, TaskTags, TaskLinks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Handle future migrations here
        },
      );
}
