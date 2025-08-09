import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getTasksByParentId(String? parentId);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> reorderTasks(List<String> taskIds);
}
