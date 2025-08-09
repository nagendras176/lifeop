// Conditional import for database connections
// This file will import the appropriate implementation based on platform

export 'open_connection_io.dart' if (dart.library.html) 'open_connection_web.dart';
