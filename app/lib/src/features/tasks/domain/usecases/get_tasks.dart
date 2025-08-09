import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks {
  final TaskRepository repository;
  
  GetTasks(this.repository);
  
  Future<List<Task>> call() async {
    return await repository.getTasks();
  }
}

class GetTasksByParentId {
  final TaskRepository repository;
  
  GetTasksByParentId(this.repository);
  
  Future<List<Task>> call(String? parentId) async {
    return await repository.getTasksByParentId(parentId);
  }
}
