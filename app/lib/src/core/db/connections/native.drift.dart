import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor openConnection() {
  return NativeDatabase(File('app_db'));
}