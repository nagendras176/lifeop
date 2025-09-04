import '../../../../core/di/providers.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/entities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_providers.g.dart';

GetTasks get getTasksProvider => serviceLocator.getTasks;
CreateTask get createTaskProvider => serviceLocator.createTask;

@riverpod
Stream<List<Task>> tasksByParentId(Ref ref, String? parentId) async* {
  final getTasksByParentId = GetTasksByParentId(serviceLocator.taskRepository);
  yield await getTasksByParentId.call(parentId);
}

final tasksByParentIdProvider = StreamProvider.family<List<Task>, String>((ref, parentId) {
  return tasksByParentId(ref, parentId);
});
