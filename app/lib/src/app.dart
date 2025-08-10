import 'package:app/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'features/tasks/presentation/pages/queue.dart';

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      home: const TaskQueueScreen(),
    );
  }
}
