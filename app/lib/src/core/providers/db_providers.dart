import 'package:app/src/core/db/app_database.dart';
import 'package:app/src/core/db/daos/drift_task_dao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_providers.g.dart';

@riverpod
AppDatabase db(Ref ref) {
  return AppDatabase();
}


@riverpod
DriftTaskDao dao(Ref ref) {
  final dbWatch = ref.watch(dbProvider);
  return DriftTaskDao(dbWatch);
}

@riverpod
Stream<List<Task>> tasksById(Ref ref, {required String id}) {
  final repo = ref.watch(daoProvider);
  return repo.getTasksStream(id); // just forward the stream
}