abstract class Failure {
  const Failure([this.message]);
  
  final String? message;
  
  @override
  String toString() => message ?? 'Failure occurred';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}
