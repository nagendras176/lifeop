import 'package:app/src/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../../features/tasks/domain/entities/task.dart' as domain;
import 'task_dao.dart';
import '../../../features/tasks/data/local/drift/mappers.dart';
import '../tables/tasks.dart';
import '../tables/tags.dart';
import '../tables/task_links.dart';

part 'drift_task_dao.g.dart';

@DriftAccessor(tables: [Tasks, Objectives, Tag, TaskLinks])
class DriftTaskDao extends DatabaseAccessor<AppDatabase> with _$DriftTaskDaoMixin implements TaskDao {
  DriftTaskDao(super.db);

  Future<domain.Task> _hydrateTask(dynamic row) async {
    // Convert the database row to TasksData
    final taskData = Task(
      id: row.id,
      parentId: row.parentId,
      orderIndex: row.orderIndex,
      title: row.title,
      description: row.description,
      notes: row.notes,
      priority: row.priority,
      taskType: row.taskType,
      deadline: row.deadline,
      color: row.color,
      reminderTime: row.reminderTime,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
    final objectivesRows = await (select(objectives)
      ..where((o) => o.taskId.equals(taskData.id)))
    .get();

final objectivesData = objectivesRows.map((o) => Objective(
      id: o.id,
      taskId: o.taskId,
      name: o.name,
      weight: o.weight,
      isCompleted: o.isCompleted,
      createdAt: o.createdAt,
    )).toList();
    // Get tags directly from the Tag table
    final tagRows = await (select(tag)
          ..where((t) => t.taskId.equals(taskData.id)))
        .get();
    
    // Convert tag rows to domain Tag objects
    final tagsData = tagRows.map((t) => domain.Tag(
      id: '${t.taskId}_${t.name}', // Generate a unique ID for the domain Tag
      name: t.name,
      color: t.color != null ? Color(t.color!) : null,
    )).toList();
    
    final linkRows = await (select(taskLinks)
          ..where((l) => l.fromTaskId.equals(taskData.id)))
        .get();
    final linkedIds = linkRows.map((l) => l.toTaskId).toList();
    
    return TaskMappers.fromComposite(taskData, objectivesData, tagsData, linkedIds);
  }

  @override
  Future<List<domain.Task>> getAllTasks() async {
    final rows = await (select(tasks)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<domain.Task?> getTaskById(String id) async {
    final row = await (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _hydrateTask(row);
  }

  @override
  Future<List<domain.Task>> getTasksByParentId(String? parentId) async {
    final query = select(tasks);
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
  Future<domain.Task> insertTask(domain.Task task) async {
    await into(tasks).insert(TaskMappers.toTasksCompanion(task));
    
    // Objectives (only for simple tasks)
    if (task.taskType == domain.TaskType.simple) {
      for (final o in task.objectives) {
        await into(objectives).insert(ObjectivesCompanion(
              id: Value(o.id),
              taskId: Value(task.id),
              name: Value(o.name),
              weight: Value(o.weight),
              isCompleted: Value(o.isCompleted),
              createdAt: Value(task.createdAt),
            ));
      }
    }
    
    // Tags - insert directly into Tag table
    for (final tag in task.tags) {
      await into(this.tag).insert(TagCompanion(
            taskId: Value(task.id),
            name: Value(tag.name),
            color: Value(tag.color?.toARGB32()),
          ));
    }
    
    // Links
    for (final toId in task.linkedTaskIds) {
      await into(taskLinks).insert(TaskLinksCompanion(
            fromTaskId: Value(task.id),
            toTaskId: Value(toId),
          ));
    }
    return (await getTaskById(task.id))!;
  }

  @override
  Future<domain.Task> updateTask(domain.Task task) async {
    await (update(tasks)..where((t) => t.id.equals(task.id))).write(TaskMappers.toTasksCompanion(task));
    
    // Replace objectives (only for simple tasks)
    await (delete(objectives)..where((o) => o.taskId.equals(task.id))).go();
    if (task.taskType == domain.TaskType.simple) {
      for (final o in task.objectives) {
        await into(objectives).insert(ObjectivesCompanion(
              id: Value(o.id),
              taskId: Value(task.id),
              name: Value(o.name),
              weight: Value(o.weight),
              isCompleted: Value(o.isCompleted),
              createdAt: Value(task.createdAt),
            ));
      }
    }
    
    // Replace tags - delete old ones and insert new ones
    await (delete(tag)..where((t) => t.taskId.equals(task.id))).go();
    for (final tag in task.tags) {
      await into(this.tag).insert(TagCompanion(
            taskId: Value(task.id),
            name: Value(tag.name),
            color: Value(tag.color?.toARGB32()),
          ));
    }
    
    // Replace links
    await (delete(taskLinks)..where((l) => l.fromTaskId.equals(task.id))).go();
    for (final toId in task.linkedTaskIds) {
      await into(taskLinks).insert(TaskLinksCompanion(
            fromTaskId: Value(task.id),
            toTaskId: Value(toId),
          ));
    }
    return (await getTaskById(task.id))!;
  }

  @override
  Future<void> deleteTask(String id) async {
    await (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> reorderTasks(List<String> taskIds) async {
    int index = 0;
    for (final id in taskIds) {
      await (update(tasks)..where((t) => t.id.equals(id))).write(TasksCompanion(orderIndex: Value(index++)));
    }
  }

  @override
  Future<List<domain.Task>> getTasksByStatus(domain.TaskStatus status) async {
    final rows = await (select(tasks)..where((t) => t.status.equals(status.name))).get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<List<domain.Task>> getTasksByPriority(domain.Priority priority) async {
    final rows = await (select(tasks)..where((t) => t.priority.equals(priority.name))).get();
    return Future.wait(rows.map(_hydrateTask));
  }

  @override
  Future<void> addTagToTask(String taskId, domain.Tag tag) async {
    await into(this.tag).insert(TagCompanion(
          taskId: Value(taskId),
          name: Value(tag.name),
          color: Value(tag.color?.toARGB32()),
        ));
  }

  @override
  Future<void> removeTagFromTask(String taskId, String tagName) async {
    await (delete(tag)
          ..where((t) => t.taskId.equals(taskId) & t.name.equals(tagName)))
        .go();
  }

  @override
  Future<void> linkTasks(String fromTaskId, String toTaskId) async {
    await into(taskLinks).insert(TaskLinksCompanion(
          fromTaskId: Value(fromTaskId),
          toTaskId: Value(toTaskId),
        ));
  }

  @override
  Future<void> unlinkTasks(String fromTaskId, String toTaskId) async {
    await (delete(taskLinks)
          ..where((l) => l.fromTaskId.equals(fromTaskId) & l.toTaskId.equals(toTaskId)))
        .go();
  }
}