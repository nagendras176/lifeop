import '../../../core/di/providers.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';

GetTasks get getTasksProvider => serviceLocator.getTasks;
CreateTask get createTaskProvider => serviceLocator.createTask;
