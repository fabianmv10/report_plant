import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plant_repository.dart';
import '../datasources/plant_remote_datasource.dart';

/// Implementación del repositorio de plantas para WEB
/// Solo usa datasource remoto (sin cache local)
class PlantRepositoryImplWeb implements PlantRepository {
  final PlantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PlantRepositoryImplWeb({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Plant>>> getAllPlants() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final plants = await remoteDataSource.getAllPlants();
      return Right(plants.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      logger.error('Error del servidor al obtener plantas', e);
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      logger.error('Error de red al obtener plantas', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado al obtener plantas', e);
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final plant = await remoteDataSource.getPlantById(id);
      return Right(plant.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> insertPlant(Plant plant) async {
    return const Left(CacheFailure('Operación no soportada en web'));
  }

  @override
  Future<Either<Failure, void>> updatePlant(Plant plant) async {
    return const Left(CacheFailure('Operación no soportada en web'));
  }

  @override
  Future<Either<Failure, void>> deletePlant(String id) async {
    return const Left(CacheFailure('Operación no soportada en web'));
  }
}
