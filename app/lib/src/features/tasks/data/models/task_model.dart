import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    super.notes,
    required super.priority,
    required super.taskType,
    super.deadline,
    required super.color,
    super.reminderTime,
    required super.createdAt,
    required super.updatedAt,
    super.status,
    super.parentId,
    super.orderIndex,
    super.objectives,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      notes: task.notes,
      priority: task.priority,
      taskType: task.taskType,
      deadline: task.deadline,
      color: task.color,
      reminderTime: task.reminderTime,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      status: task.status,
      parentId: task.parentId,
      orderIndex: task.orderIndex,
      objectives: task.objectives,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      notes: notes,
      priority: priority,
      taskType: taskType,
      deadline: deadline,
      color: color,
      reminderTime: reminderTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      parentId: parentId,
      orderIndex: orderIndex,
      objectives: objectives,
    );
  }
}
