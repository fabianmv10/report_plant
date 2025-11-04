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
  const ServerFailure([super.message = 'Error del servidor', super.code]);
}

/// Falla de conexión (sin internet, timeout, etc.)
class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'Error de conexión', super.code]);
}

/// Falla de caché/base de datos local
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché local', super.code]);
}

/// Falla de validación (datos inválidos)
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos', super.code]);
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación', super.code]);
}

/// Falla de autorización (sin permisos)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message = 'Sin permisos', super.code]);
}

/// Falla no encontrada (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado', super.code]);
}

/// Falla desconocida
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido', super.code]);
}
