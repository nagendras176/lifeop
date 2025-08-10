import 'package:app/src/core/db/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_providers.g.dart';

@riverpod
AppDatabase db(Ref ref) {
  return AppDatabase();
}