import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

/// Repositorio abstracto para autenticación
abstract class AuthRepository {
  /// Login con credenciales
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Obtener usuario actual
  Future<Either<Failure, AuthUser?>> getCurrentUser();

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated();

  /// Refrescar token
  Future<Either<Failure, AuthToken>> refreshToken();

  /// Guardar token
  Future<void> saveToken(AuthToken token);

  /// Obtener token guardado
  Future<AuthToken?> getToken();

  /// Eliminar token
  Future<void> clearToken();
}
