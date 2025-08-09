import 'package:drift/drift.dart';
import '../../../../features/tasks/domain/entities/task.dart';
import '../app_database.dart';
import 'task_dao.dart';
import '../../../../features/tasks/data/local/drift/mappers.dart';

class DriftTaskDao implements TaskDao {
  final AppDatabase db;
  DriftTaskDao(this.db);

  Future<Task> _hydrateTask(TasksData row) async {
    final objectives = await (db.select(db.objectives)
          ..where((o) => o.taskId.equals(row.id)))
        .get();
    final tagRows = await (db.select(db.tags)
          ..whereExists(db.select(db.taskTags)
              ..where((tt) => tt.taskId.equals(row.id))
              ..where((tt) => tt.tagId.equalsExp(db.tags.id))))
        .get();
    final linkRows = await (db.select(db.taskLinks)
          ..where((l) => l.fromTaskId.equals(row.id)))
        .get();
    final linkedIds = linkRows.map((l) => l.toTaskId).toList();
    return TaskMappers.fromComposite(row, objectives, tagRows, linkedIds);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final rows = await (db.select(db.tasks)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final row = await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _hydrateTask(row);
  }

  @override
  Future<List<Task>> getTasksByParentId(String? parentId) async {
    final query = db.select(db.tasks);
    if (parentId == null) {
      query.where((t) => t.parentId.isNull());
    } else {
      query.where((t) => t.parentId.equals(parentId));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.orderIndex)]);
    final rows = await query.get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<Task> insertTask(Task task) async {
    await db.into(db.tasks).insert(TaskMappers.toTasksCompanion(task));
    // Objectives (only for simple tasks)
    if (task.taskType == TaskType.simple) {
      for (final o in task.objectives) {
        await db.into(db.objectives).insert(ObjectivesCompanion(
              id: Value(o.id),
              taskId: Value(task.id),
              name: Value(o.name),
              weight: Value(o.weight),
              isCompleted: Value(o.isCompleted),
              createdAt: Value(task.createdAt),
            ));
      }
    }
    // Tags (upsert naive)
    for (final tag in task.tags) {
      await db.into(db.tags).insertOnConflictUpdate(TagsCompanion(
            id: Value(tag.id),
            name: Value(tag.name),
            color: Value(tag.color?.value),
            createdAt: Value(task.createdAt),
            updatedAt: Value(task.updatedAt),
          ));
      await db.into(db.taskTags).insert(TaskTagsCompanion(
            taskId: Value(task.id),
            tagId: Value(tag.id),
          ));
    }
    // Links
    for (final toId in task.linkedTaskIds) {
      await db.into(db.taskLinks).insert(TaskLinksCompanion(
            fromTaskId: Value(task.id),
            toTaskId: Value(toId),
          ));
    }
    return (await getTaskById(task.id))!;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(TaskMappers.toTasksCompanion(task));
    // Replace objectives (only for simple tasks)
    await (db.delete(db.objectives)..where((o) => o.taskId.equals(task.id))).go();
    if (task.taskType == TaskType.simple) {
      for (final o in task.objectives) {
        await db.into(db.objectives).insert(ObjectivesCompanion(
              id: Value(o.id),
              taskId: Value(task.id),
              name: Value(o.name),
              weight: Value(o.weight),
              isCompleted: Value(o.isCompleted),
              createdAt: Value(task.createdAt),
            ));
      }
    }
    // Replace tags
    await (db.delete(db.taskTags)..where((tt) => tt.taskId.equals(task.id))).go();
    for (final tag in task.tags) {
      await db.into(db.tags).insertOnConflictUpdate(TagsCompanion(
            id: Value(tag.id),
            name: Value(tag.name),
            color: Value(tag.color?.value),
            createdAt: Value(task.createdAt),
            updatedAt: Value(task.updatedAt),
          ));
      await db.into(db.taskTags).insert(TaskTagsCompanion(
            taskId: Value(task.id),
            tagId: Value(tag.id),
          ));
    }
    // Replace links
    await (db.delete(db.taskLinks)..where((l) => l.fromTaskId.equals(task.id))).go();
    for (final toId in task.linkedTaskIds) {
      await db.into(db.taskLinks).insert(TaskLinksCompanion(
            fromTaskId: Value(task.id),
            toTaskId: Value(toId),
          ));
    }
    return (await getTaskById(task.id))!;
  }

  @override
  Future<void> deleteTask(String id) async {
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> reorderTasks(List<String> taskIds) async {
    int index = 0;
    for (final id in taskIds) {
      await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(TasksCompanion(orderIndex: Value(index++)));
    }
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final rows = await (db.select(db.tasks)..where((t) => t.status.equals(status.name))).get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<List<Task>> getTasksByPriority(Priority priority) async {
    final rows = await (db.select(db.tasks)..where((t) => t.priority.equals(priority.name))).get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<void> addTagToTask(String taskId, Tag tag) async {
    await db.into(db.tags).insertOnConflictUpdate(TagsCompanion(
          id: Value(tag.id),
          name: Value(tag.name),
          color: Value(tag.color?.value),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
    await db.into(db.taskTags).insert(TaskTagsCompanion(
          taskId: Value(taskId),
          tagId: Value(tag.id),
        ));
  }

  @override
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    await (db.delete(db.taskTags)
          ..where((tt) => tt.taskId.equals(taskId) & tt.tagId.equals(tagId)))
        .go();
  }

  @override
  Future<void> linkTasks(String fromTaskId, String toTaskId) async {
    await db.into(db.taskLinks).insert(TaskLinksCompanion(
          fromTaskId: Value(fromTaskId),
          toTaskId: Value(toTaskId),
        ));
  }

  @override
  Future<void> unlinkTasks(String fromTaskId, String toTaskId) async {
    await (db.delete(db.taskLinks)
          ..where((l) => l.fromTaskId.equals(fromTaskId) & l.toTaskId.equals(toTaskId)))
        .go();
  }
}