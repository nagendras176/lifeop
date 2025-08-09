import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../../../core/utils/date_time.dart';

class TaskQueueScreen extends StatefulWidget {
  const TaskQueueScreen({super.key});

  @override
  State<TaskQueueScreen> createState() => _TaskQueueScreenState();
}

class _TaskQueueScreenState extends State<TaskQueueScreen> {
  final List<Task> _tasks = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Priority _selectedPriority = Priority.medium;

  @override
  void initState() {
    super.initState();
    // Add some sample tasks
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Complete Project Proposal',
        description: 'Finish the quarterly project proposal document',
        priority: Priority.high,
        taskType: TaskType.simple,
        color: Colors.blue,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        objectives: [
          Objective(id: 'obj1', name: 'Research', weight: 30, isCompleted: true),
          Objective(id: 'obj2', name: 'Write Draft', weight: 40, isCompleted: false),
          Objective(id: 'obj3', name: 'Review', weight: 30, isCompleted: false),
        ],
      ),
      Task(
        id: '2',
        title: 'Review Code Changes',
        description: 'Review pull requests for the main branch',
        priority: Priority.medium,
        taskType: TaskType.simple,
        color: Colors.green,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        objectives: [
          Objective(id: 'obj4', name: 'Code Review', weight: 60, isCompleted: true),
          Objective(id: 'obj5', name: 'Testing', weight: 40, isCompleted: false),
        ],
      ),
      Task(
        id: '3',
        title: 'Team Meeting',
        description: 'Weekly team sync meeting',
        priority: Priority.urgent,
        taskType: TaskType.composite,
        color: Colors.orange,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        objectives: [],
      ),
    ]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      _tasks.add(Task(
        id: _generateId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        taskType: TaskType.simple,
        color: Colors.blue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        objectives: [],
      ));
    });

    _titleController.clear();
    _descriptionController.clear();
    _selectedPriority = Priority.medium;
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      final task = _tasks[index];
      final newStatus = task.status == TaskStatus.completed 
          ? TaskStatus.pending 
          : TaskStatus.completed;
      _tasks[index] = task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    });
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Queue'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Add Task Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Priority: '),
                    DropdownButton<Priority>(
                      value: _selectedPriority,
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (Priority? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Task List
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final progress = _calculateProgress(task);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.status == TaskStatus.completed,
                      onChanged: (_) => _toggleTaskCompletion(index),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.status == TaskStatus.completed 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty)
                          Text(task.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.priority.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (task.deadline != null)
                              Text(
                                'Due: ${DateTimeUtils.formatDate(task.deadline!)}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        if (task.objectives.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(task.color),
                          ),
                          Text(
                            '$progress% Complete',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          // TODO: Implement edit functionality
                        } else if (value == 'delete') {
                          setState(() {
                            _tasks.removeAt(index);
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calculateProgress(Task task) {
    if (task.objectives.isEmpty) return 0;
    
    int totalWeightedProgress = 0;
    int totalWeight = 0;
    
    for (final objective in task.objectives) {
      totalWeightedProgress += (objective.isCompleted ? 100 : 0) * objective.weight;
      totalWeight += objective.weight;
    }
    
    return totalWeight > 0 ? totalWeightedProgress ~/ totalWeight : 0;
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }
}
