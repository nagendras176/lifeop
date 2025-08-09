import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'package:app/src/core/db/daos/task_dao.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDao dao;
  TaskRepositoryImpl(this.dao);

  @override
  Future<List<Task>> getTasks() async {
    return dao.getAllTasks();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return dao.getTaskById(id);
  }

  @override
  Future<List<Task>> getTasksByParentId(String? parentId) async {
    return dao.getTasksByParentId(parentId);
  }

  @override
  Future<Task> createTask(Task task) async {
    return dao.insertTask(task);
  }

  @override
  Future<Task> updateTask(Task task) async {
    return dao.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    return dao.deleteTask(id);
  }

  @override
  Future<void> reorderTasks(List<String> taskIds) async {
    return dao.reorderTasks(taskIds);
  }
}
