import 'package:app/src/core/db/daos/drift_task_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app/src/core/providers/db_providers.dart';

part 'dao_providers.g.dart';

@riverpod
DriftTaskDao driftTaskDao(Ref ref) {
  final dbInstance = ref.watch(dbProvider);
  return DriftTaskDao(dbInstance);
}
