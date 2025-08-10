import 'package:flutter/material.dart';

enum TaskType { simple, composite }
enum Priority { low, medium, high, urgent }
enum TaskStatus { pending, in_progress, completed, cancelled }

class Objective {
  final String id;
  final String name;
  final int weight;
  final bool isCompleted;

  const Objective({
    required this.id,
    required this.name,
    required this.weight,
    this.isCompleted = false,
  });

  Objective copyWith({
    String? id,
    String? name,
    int? weight,
    bool? isCompleted,
  }) {
    return Objective(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'weight': weight,
    'isCompleted': isCompleted,
  };

  factory Objective.fromJson(Map<String, dynamic> json) => Objective(
    id: json['id'] as String,
    name: json['name'] as String,
    weight: json['weight'] as int,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class Tag {
  final String id;
  final String name;
  final Color? color;

  const Tag({
    required this.id,
    required this.name,
    this.color,
  });

  Tag copyWith({String? id, String? name, Color? color}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color?.toARGB32(),
      };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] != null ? Color(json['color'] as int) : null,
      );
}

class Task {
  final String id;
  final String title;
  final String description;
  final String? notes;
  final Priority priority;
  final TaskType taskType;
  final DateTime? deadline;
  final Color color;
  final DateTime? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TaskStatus status;
  final String? parentId;
  final int orderIndex;
  final List<Objective> objectives;
  final List<Tag> tags;
  final List<String> linkedTaskIds;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    this.notes,
    required this.priority,
    required this.taskType,
    this.deadline,
    required this.color,
    this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
    this.status = TaskStatus.pending,
    this.parentId,
    this.orderIndex = 0,
    this.objectives = const [],
    this.tags = const [],
    this.linkedTaskIds = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? notes,
    Priority? priority,
    TaskType? taskType,
    DateTime? deadline,
    Color? color,
    DateTime? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskStatus? status,
    String? parentId,
    int? orderIndex,
    List<Objective>? objectives,
    List<Tag>? tags,
    List<String>? linkedTaskIds,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      taskType: taskType ?? this.taskType,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      parentId: parentId ?? this.parentId,
      orderIndex: orderIndex ?? this.orderIndex,
      objectives: objectives ?? this.objectives,
      tags: tags ?? this.tags,
      linkedTaskIds: linkedTaskIds ?? this.linkedTaskIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'notes': notes,
    'priority': priority.name,
    'taskType': taskType.name,
    'deadline': deadline?.toIso8601String(),
    'color': color.toARGB32(),
    'reminderTime': reminderTime?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'status': status.name,
    'parentId': parentId,
    'orderIndex': orderIndex,
    'objectives': objectives.map((o) => o.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'linkedTaskIds': linkedTaskIds,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    notes: json['notes'] as String?,
    priority: Priority.values.firstWhere((e) => e.name == json['priority']),
    taskType: TaskType.values.firstWhere((e) => e.name == json['taskType']),
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    color: Color(json['color'] as int),
    reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
    parentId: json['parentId'] as String?,
    orderIndex: json['orderIndex'] as int? ?? 0,
    objectives: (json['objectives'] as List<dynamic>?)
            ?.map((o) => Objective.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [],
    tags: (json['tags'] as List<dynamic>?)
            ?.map((t) => Tag.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [],
    linkedTaskIds: (json['linkedTaskIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}
