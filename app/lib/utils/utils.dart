import 'dart:math';

class Utils {
  static final Random _random = Random.secure();
  
  /// Generate a simple UUID-like string for development purposes
  /// In production, use a proper UUID package
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(1000000);
    return '${timestamp}_$random';
  }
}
