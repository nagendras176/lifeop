import '../../../../core/di/providers.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/entities/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_providers.g.dart';

GetTasks get getTasksProvider => serviceLocator.getTasks;
CreateTask get createTaskProvider => serviceLocator.createTask;

@riverpod
Future<List<Task>> tasksByParentId(Ref ref, String? parentId) async {
  final getTasksByParentId = GetTasksByParentId(serviceLocator.taskRepository);
  return await getTasksByParentId.call(parentId);
}
