import '../db/app_database.dart';
import '../db/connection/open_connection.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/create_task.dart';

// Simple dependency injection without external packages
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final DatabaseConnection _databaseConnection = IoDatabaseConnection();
  late final AppDatabase _appDatabase = AppDatabase(_databaseConnection);
  late final TaskRepository _taskRepository = TaskRepositoryImpl();
  late final GetTasks _getTasks = GetTasks(_taskRepository);
  late final CreateTask _createTask = CreateTask(_taskRepository);

  DatabaseConnection get databaseConnection => _databaseConnection;
  AppDatabase get appDatabase => _appDatabase;
  TaskRepository get taskRepository => _taskRepository;
  GetTasks get getTasks => _getTasks;
  CreateTask get createTask => _createTask;
}

final serviceLocator = ServiceLocator();
