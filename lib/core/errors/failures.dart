import 'package:equatable/equatable.dart';

/// Clase base para representar fallas en la aplicación
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Falla de servidor (5xx)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor', int? code])
      : super(message, code);
}

/// Falla de conexión (sin internet, timeout, etc.)
class ConnectionFailure extends Failure {
  const ConnectionFailure([String message = 'Error de conexión', int? code])
      : super(message, code);
}

/// Falla de caché/base de datos local
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de caché local', int? code])
      : super(message, code);
}

/// Falla de validación (datos inválidos)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Datos inválidos', int? code])
      : super(message, code);
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Error de autenticación', int? code])
      : super(message, code);
}

/// Falla de autorización (sin permisos)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([String message = 'Sin permisos', int? code])
      : super(message, code);
}

/// Falla no encontrada (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Recurso no encontrado', int? code])
      : super(message, code);
}

/// Falla desconocida
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Error desconocido', int? code])
      : super(message, code);
}
