import '../../../features/tasks/domain/entities/task.dart';

abstract class TaskDao {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getTasksByParentId(String? parentId);
  Future<Task> insertTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);

  // Tags
  Future<void> addTagToTask(String taskId, Tag tag);
  Future<void> removeTagFromTask(String taskId, String tagName);

  // Links
  Future<void> linkTasks(String fromTaskId, String toTaskId);
  Future<void> unlinkTasks(String fromTaskId, String toTaskId);
}
