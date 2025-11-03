/// Excepciones personalizadas para la capa de datos

/// Excepción de servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (código: $statusCode)';
}

/// Excepción de caché/base de datos local
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción de red/conexión
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción de validación
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  ValidationException(this.message, [this.errors]);

  @override
  String toString() => 'ValidationException: $message';
}

/// Excepción de autenticación
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Excepción de autorización
class AuthorizationException implements Exception {
  final String message;

  AuthorizationException(this.message);

  @override
  String toString() => 'AuthorizationException: $message';
}
