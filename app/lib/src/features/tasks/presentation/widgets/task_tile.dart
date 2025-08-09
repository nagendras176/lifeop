import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onCheckboxChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress(task);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.status == TaskStatus.completed,
          onChanged: onCheckboxChanged,
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
                    'Due: ${_formatDate(task.deadline!)}',
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show more options menu
              },
            ),
          ],
        ),
        onTap: onTap,
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}
