import 'package:app/src/core/db/daos/drift_task_dao.dart';
import 'package:drift/drift.dart';
import 'connections/index.dart';
import 'tables/tasks.dart';
import 'tables/tags.dart';
import 'tables/task_links.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Tasks, Objectives, Tag, TaskLinks],
  daos: [DriftTaskDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

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
