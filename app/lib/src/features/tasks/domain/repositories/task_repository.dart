import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getTasksByParentId(String? parentId);
  Future<Task> insertTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
}
