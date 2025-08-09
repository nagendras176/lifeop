import '../db/app_database.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/create_task.dart';
import '../db/daos/drift_task_dao.dart';

// Simple dependency injection without external packages
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AppDatabase _appDatabase = AppDatabase();
  late final DriftTaskDao _taskDao = DriftTaskDao(_appDatabase);
  late final TaskRepository _taskRepository = TaskRepositoryImpl(_taskDao);
  late final GetTasks _getTasks = GetTasks(_taskRepository);
  late final CreateTask _createTask = CreateTask(_taskRepository);

  AppDatabase get appDatabase => _appDatabase;
  TaskRepository get taskRepository => _taskRepository;
  GetTasks get getTasks => _getTasks;
  CreateTask get createTask => _createTask;
}

final serviceLocator = ServiceLocator();
