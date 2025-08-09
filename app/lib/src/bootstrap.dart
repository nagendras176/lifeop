import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/providers.dart';

void bootstrap() {
  // Ensure singletons are created
  // The first access will initialize the database connection lazily
  final _ = serviceLocator.appDatabase;
  runApp(const TaskTrackerApp());
}
