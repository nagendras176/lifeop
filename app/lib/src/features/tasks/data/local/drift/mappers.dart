import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../../../domain/entities/task.dart';
import '../../../../core/db/app_database.dart';

class TaskMappers {
  static Task fromComposite(
    TasksData task,
    List<ObjectivesData> objectives,
    List<TagsData> tags,
    List<String> linkedIds,
  ) {
    return Task(
      id: task.id,
      title: task.title,
      description: task.description,
      notes: task.notes,
      priority: Priority.values.firstWhere((e) => e.name == task.priority),
      taskType: TaskType.values.firstWhere((e) => e.name == task.taskType),
      deadline: task.deadline,
      color: Color(task.color),
      reminderTime: task.reminderTime,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      status: TaskStatus.values.firstWhere((e) => e.name == task.status),
      parentId: task.parentId,
      orderIndex: task.orderIndex,
      objectives: objectives
          .map((o) => Objective(
                id: o.id,
                name: o.name,
                weight: o.weight,
                isCompleted: o.isCompleted,
              ))
          .toList(),
      tags: tags
          .map((t) => Tag(
                id: t.id,
                name: t.name,
                color: t.color != null ? Color(t.color!) : null,
              ))
          .toList(),
      linkedTaskIds: linkedIds,
    );
  }

  static TasksCompanion toTasksCompanion(Task task) {
    return TasksCompanion(
      id: Value(task.id),
      parentId: Value(task.parentId),
      orderIndex: Value(task.orderIndex),
      title: Value(task.title),
      description: Value(task.description),
      notes: Value(task.notes),
      priority: Value(task.priority.name),
      taskType: Value(task.taskType.name),
      deadline: Value(task.deadline),
      color: Value(task.color.value),
      reminderTime: Value(task.reminderTime),
      status: Value(task.status.name),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
    );
  }
}
