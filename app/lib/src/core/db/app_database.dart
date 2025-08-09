import 'connection/open_connection.dart';

class AppDatabase {
  final DatabaseConnection _connection;
  
  AppDatabase(this._connection);
  
  Future<void> initialize() async {
    await _connection.open();
    // TODO: Initialize database schema
  }
  
  Future<void> close() async {
    await _connection.close();
  }
  
  bool get isOpen => _connection.isOpen;
}
