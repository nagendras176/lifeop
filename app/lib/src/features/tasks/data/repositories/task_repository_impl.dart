import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  // TODO: Inject actual database DAO
  final List<Task> _tasks = [];
  
  @override
  Future<List<Task>> getTasks() async {
    return _tasks;
  }
  
  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<Task>> getTasksByParentId(String? parentId) async {
    return _tasks.where((task) => task.parentId == parentId).toList();
  }
  
  @override
  Future<Task> createTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    _tasks.add(taskModel);
    return taskModel;
  }
  
  @override
  Future<Task> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final taskModel = TaskModel.fromEntity(task);
      _tasks[index] = taskModel;
      return taskModel;
    }
    throw Exception('Task not found');
  }
  
  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
  
  @override
  Future<void> reorderTasks(List<String> taskIds) async {
    // TODO: Implement reordering logic
  }
}
