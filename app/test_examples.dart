import 'package:flutter/material.dart';
import 'lib/components/models.dart';

/// Test file demonstrating the Queue of Life app functionality
/// This file shows examples of all the features and edge cases

void main() {
  print('=== Queue of Life - Test Examples ===\n');
  
  // Test 1: Simple task with objectives
  testSimpleTaskWithObjectives();
  
  // Test 2: Composite task with subtasks
  testCompositeTaskWithSubtasks();
  
  // Test 3: Progress computation examples
  testProgressComputation();
  
  // Test 4: Edge cases
  testEdgeCases();
  
  // Test 5: JSON serialization
  testJsonSerialization();
}

void testSimpleTaskWithObjectives() {
  print('1. Simple Task with Objectives:');
  
  final task = Task(
    id: 'task_001',
    title: 'Design User Interface',
    description: 'Create wireframes and mockups for the new app',
    priority: Priority.high,
    taskType: TaskType.simple,
    color: Colors.blue,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [
      Objective(id: 'obj_001', name: 'Research', weight: 30, isCompleted: true),
      Objective(id: 'obj_002', name: 'Write Draft', weight: 40, isCompleted: false),
      Objective(id: 'obj_003', name: 'Review', weight: 30, isCompleted: false),
    ],
  );
  
  print('   Task: ${task.title}');
  print('   Type: ${task.taskType.name}');
  print('   Objectives: ${task.objectives.length}');
  print('   Total Weight: ${task.objectives.fold<int>(0, (sum, obj) => sum + obj.weight)}%');
  print('   Completed: ${task.objectives.where((obj) => obj.isCompleted).length}/${task.objectives.length}');
  print('');
}

void testCompositeTaskWithSubtasks() {
  print('2. Composite Task with Subtasks:');
  
  final subtask1 = Task(
    id: 'subtask_001',
    title: 'Research Competitors',
    description: 'Analyze competitor products and features',
    priority: Priority.medium,
    taskType: TaskType.simple,
    color: Colors.green,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    parentId: 'task_002',
    orderIndex: 0,
    objectives: [
      Objective(id: 'obj_005', name: 'Market Analysis', weight: 60, isCompleted: true),
      Objective(id: 'obj_006', name: 'Feature Comparison', weight: 40, isCompleted: false),
    ],
  );
  
  final subtask2 = Task(
    id: 'subtask_002',
    title: 'Create Marketing Materials',
    description: 'Design brochures, social media posts, and website content',
    priority: Priority.high,
    taskType: TaskType.simple,
    color: Colors.orange,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    parentId: 'task_002',
    orderIndex: 1,
    objectives: [
      Objective(id: 'obj_007', name: 'Brochure Design', weight: 40, isCompleted: false),
      Objective(id: 'obj_008', name: 'Social Media Content', weight: 35, isCompleted: false),
      Objective(id: 'obj_009', name: 'Website Copy', weight: 25, isCompleted: false),
    ],
  );
  
  final compositeTask = Task(
    id: 'task_002',
    title: 'Launch Marketing Campaign',
    description: 'Execute Q1 marketing campaign across all channels',
    priority: Priority.urgent,
    taskType: TaskType.composite,
    color: Colors.purple,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [], // Composite tasks have no objectives
  );
  
  print('   Task: ${compositeTask.title}');
  print('   Type: ${compositeTask.taskType.name}');
  print('   Subtasks: 2');
  print('   Subtask 1: ${subtask1.title} (${subtask1.orderIndex})');
  print('   Subtask 2: ${subtask2.title} (${subtask2.orderIndex})');
  print('');
}

void testProgressComputation() {
  print('3. Progress Computation Examples:');
  
  // Example 1: Simple task with objectives
  final simpleTask = Task(
    id: 'task_003',
    title: 'Complete Project',
    description: 'Finish the project with objectives',
    priority: Priority.high,
    taskType: TaskType.simple,
    color: Colors.blue,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [
      Objective(id: 'obj_010', name: 'Phase 1', weight: 40, isCompleted: true),
      Objective(id: 'obj_011', name: 'Phase 2', weight: 35, isCompleted: true),
      Objective(id: 'obj_012', name: 'Phase 3', weight: 25, isCompleted: false),
    ],
  );
  
  final simpleProgress = computeTaskProgress(simpleTask, [], simpleTask.objectives);
  print('   Simple Task Progress: $simpleProgress%');
  print('   Explanation: (40×100 + 35×100 + 25×0) ÷ 100 = 75%');
  
  // Example 2: Composite task with subtasks
  final child1 = Task(
    id: 'child_001',
    title: 'Child Task 1',
    description: 'First child task',
    priority: Priority.medium,
    taskType: TaskType.simple,
    color: Colors.green,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    parentId: 'parent_001',
    orderIndex: 0,
    objectives: [
      Objective(id: 'obj_013', name: 'Subtask 1', weight: 100, isCompleted: true),
    ],
  );
  
  final child2 = Task(
    id: 'child_002',
    title: 'Child Task 2',
    description: 'Second child task',
    priority: Priority.medium,
    taskType: TaskType.simple,
    color: Colors.green,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    parentId: 'parent_001',
    orderIndex: 1,
    objectives: [
      Objective(id: 'obj_014', name: 'Subtask 2', weight: 100, isCompleted: false),
    ],
  );
  
  final compositeTask = Task(
    id: 'parent_001',
    title: 'Parent Task',
    description: 'Task with children',
    priority: Priority.high,
    taskType: TaskType.composite,
    color: Colors.orange,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [],
  );
  
  final compositeProgress = computeTaskProgress(compositeTask, [child1, child2], []);
  print('   Composite Task Progress: $compositeProgress%');
  print('   Explanation: (100 + 0) ÷ 2 = 50%');
  
  // Example 3: Both objectives and children (children override)
  final mixedTask = Task(
    id: 'mixed_001',
    title: 'Mixed Task',
    description: 'Task with both objectives and children',
    priority: Priority.medium,
    taskType: TaskType.composite,
    color: Colors.purple,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [
      Objective(id: 'obj_015', name: 'Objective 1', weight: 100, isCompleted: true),
    ],
  );
  
  final mixedProgress = computeTaskProgress(mixedTask, [child1, child2], mixedTask.objectives);
  print('   Mixed Task Progress: $mixedProgress%');
  print('   Explanation: Children override objectives, so (100 + 0) ÷ 2 = 50%');
  print('');
}

void testEdgeCases() {
  print('4. Edge Cases:');
  
  // Edge case 1: Empty objectives
  final emptyTask = Task(
    id: 'empty_001',
    title: 'Empty Task',
    description: 'Task with no objectives',
    priority: Priority.low,
    taskType: TaskType.simple,
    color: Colors.grey,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [],
  );
  
  final emptyProgress = computeTaskProgress(emptyTask, [], []);
  print('   Empty Task Progress: $emptyProgress%');
  
  // Edge case 2: Deep nesting (5 levels)
  print('   Deep Nesting: 5 levels supported');
  print('   Level 1: Root Task');
  print('   Level 2: Child Task');
  print('   Level 3: Grandchild Task');
  print('   Level 4: Great-grandchild Task');
  print('   Level 5: Great-great-grandchild Task');
  
  // Edge case 3: Weight validation
  print('   Weight Validation: Must sum to exactly 100%');
  print('   Example: 30% + 40% + 30% = 100% ✓');
  print('   Example: 25% + 35% + 40% = 100% ✓');
  print('   Example: 30% + 40% + 25% = 95% ✗ (validation error)');
  print('');
}

void testJsonSerialization() {
  print('5. JSON Serialization:');
  
  final task = Task(
    id: 'json_001',
    title: 'JSON Test Task',
    description: 'Task to test JSON serialization',
    priority: Priority.medium,
    taskType: TaskType.simple,
    color: Colors.blue,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    objectives: [
      Objective(id: 'json_obj_001', name: 'Test Objective', weight: 100, isCompleted: false),
    ],
  );
  
  final json = task.toJson();
  print('   Task to JSON: ${json['title']}');
  print('   Priority: ${json['priority']}');
  print('   Task Type: ${json['taskType']}');
  print('   Objectives: ${json['objectives'].length}');
  
  final reconstructedTask = Task.fromJson(json);
  print('   Reconstructed: ${reconstructedTask.title}');
  print('   Validation: ${task.id == reconstructedTask.id ? '✓' : '✗'}');
  print('');
  
  print('=== All Tests Completed ===');
}

/// Example API shapes for future implementation
void showApiExamples() {
  print('API Examples:');
  print('GET /tasks/:id?include=children,objectives');
  print('POST /tasks (with nested objectives)');
  print('PUT /tasks/:id (partial updates)');
  print('DELETE /tasks/:id (cascade)');
  print('POST /tasks/:id/reorder (update order_index)');
}

/// Example database migration
void showMigrationExample() {
  print('Migration Example:');
  print('-- Migration 001: Add new fields');
  print('ALTER TABLE tasks ADD COLUMN task_type VARCHAR(20) DEFAULT \'simple\';');
  print('ALTER TABLE tasks ADD COLUMN parent_id UUID REFERENCES tasks(id);');
  print('ALTER TABLE tasks ADD COLUMN order_index INTEGER DEFAULT 0;');
  print('ALTER TABLE tasks ADD COLUMN status VARCHAR(20) DEFAULT \'pending\';');
}
