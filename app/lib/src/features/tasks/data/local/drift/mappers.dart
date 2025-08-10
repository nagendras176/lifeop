import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../../../domain/entities/task.dart' as domain;
import '../../../../../core/db/app_database.dart';

class TaskMappers {
  static domain.Task fromComposite(
    Task task,
    List<Objective> objectives,
    List<domain.Tag> tags,
    List<String> linkedIds,
  ) {
    return domain.Task(
      id: task.id,
      title: task.title,
      description: task.description ?? '',
      notes: task.notes,
      priority: domain.Priority.values.firstWhere((e) => e.name == task.priority),
      taskType: domain.TaskType.values.firstWhere((e) => e.name == task.taskType),
      deadline: task.deadline,
      color: Color(task.color ?? 0),
      reminderTime: task.reminderTime,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      status: domain.TaskStatus.values.firstWhere((e) => e.name == task.status),
      parentId: task.parentId,
      orderIndex: task.orderIndex,
      objectives: objectives
          .map((o) => domain.Objective(
                id: o.id,
                name: o.name,
                weight: o.weight,
                isCompleted: o.isCompleted,
              ))
          .toList(),
      tags: tags,
      linkedTaskIds: linkedIds,
    );
  }

  static TasksCompanion toTasksCompanion(domain.Task task) {
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
      color: Value(task.color.toARGB32()),
      reminderTime: Value(task.reminderTime),
      status: Value(task.status.name),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
    );
  }
}
