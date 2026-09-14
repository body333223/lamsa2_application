/// Base Failure class for domain layer error representation
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'يرجى تسجيل الدخول مجدداً']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'فشل في قراءة البيانات المحلية']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
