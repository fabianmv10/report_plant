import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Login
class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, AuthToken>> call({
    required String username,
    required String password,
  }) async {
    // Validación básica
    if (username.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Usuario y contraseña requeridos'));
    }

    final result = await repository.login(
      username: username,
      password: password,
    );

    // Si el login fue exitoso, guardar el token
    return result.fold(
      (failure) => Left(failure),
      (token) async {
        await repository.saveToken(token);
        return Right(token);
      },
    );
  }
}

/// Caso de uso: Logout
class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Either<Failure, void>> call() async {
    await repository.clearToken();
    return await repository.logout();
  }
}

/// Caso de uso: Obtener usuario actual
class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, AuthUser?>> call() async {
    return await repository.getCurrentUser();
  }
}
