import 'package:flutter/material.dart';
import '../../features/tasks/presentation/pages/task_queue_screen.dart';
import '../../features/tasks/presentation/pages/task_definition_screen.dart';
import '../../features/tasks/domain/entities/task.dart';

class AppRouter {
  static const String home = '/';
  static const String createTask = '/create-task';
  static const String editTask = '/edit-task';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const TaskQueueScreen(),
        );
      
      case createTask:
        return MaterialPageRoute(
          builder: (_) => TaskDefinitionScreen(
            onTaskSaved: (task) {
              // TODO: Handle task creation
            },
          ),
        );
      
      case editTask:
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) => TaskDefinitionScreen(
            taskToEdit: task,
            onTaskSaved: (updatedTask) {
              // TODO: Handle task update
            },
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
