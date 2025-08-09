import '../../../features/tasks/domain/entities/task.dart';

abstract class TaskDao {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getTasksByParentId(String? parentId);
  Future<Task> insertTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> reorderTasks(List<String> taskIds);
  Future<List<Task>> getTasksByStatus(TaskStatus status);
  Future<List<Task>> getTasksByPriority(Priority priority);
}
