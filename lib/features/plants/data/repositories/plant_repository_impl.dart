import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plant_repository.dart';
import '../datasources/plant_local_datasource.dart';
import '../datasources/plant_remote_datasource.dart';
import '../models/plant_model.dart';

/// Implementación del repositorio de plantas
/// Maneja lógica de caché y modo offline
class PlantRepositoryImpl implements PlantRepository {
  final PlantRemoteDataSource remoteDataSource;
  final PlantLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PlantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Plant>>> getAllPlants() async {
    try {
      // Verificar conectividad
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Obtener de la API
        try {
          final remotePlants = await remoteDataSource.getAllPlants();

          // Cachear localmente
          await localDataSource.cachePlants(remotePlants);

          // Convertir a entidades de dominio
          final plants = remotePlants.map((model) => model.toEntity()).toList();
          return Right(plants);
        } on ServerException catch (e) {
          logger.warning('Error al obtener plantas remotas, usando caché', e);
          // Si falla el servidor, intentar caché
          return _getPlantsFromCache();
        } on NetworkException catch (e) {
          logger.warning('Error de red, usando caché', e);
          return _getPlantsFromCache();
        }
      } else {
        // Sin conexión, usar caché
        logger.info('Sin conexión, usando caché local');
        return _getPlantsFromCache();
      }
    } catch (e) {
      logger.error('Error inesperado en getAllPlants', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Plant>>> _getPlantsFromCache() async {
    try {
      final localPlants = await localDataSource.getAllPlants();
      final plants = localPlants.map((model) => model.toEntity()).toList();

      if (plants.isEmpty) {
        return const Left(CacheFailure('No hay plantas en caché'));
      }

      return Right(plants);
    } on CacheException catch (e) {
      logger.error('Error al obtener plantas del caché', e);
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remotePlant = await remoteDataSource.getPlantById(id);
          await localDataSource.insertPlant(remotePlant);
          return Right(remotePlant.toEntity());
        } on ServerException catch (e) {
          logger.warning('Error al obtener planta remota, usando caché', e);
          return _getPlantFromCache(id);
        }
      } else {
        return _getPlantFromCache(id);
      }
    } catch (e) {
      logger.error('Error inesperado en getPlantById', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, Plant>> _getPlantFromCache(String id) async {
    try {
      final localPlant = await localDataSource.getPlantById(id);
      return Right(localPlant.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> insertPlant(Plant plant) async {
    try {
      final plantModel = PlantModel.fromEntity(plant);
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Insertar en servidor
        await remoteDataSource.insertPlant(plantModel);
      }

      // Siempre guardar localmente
      await localDataSource.insertPlant(plantModel);

      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error al insertar planta en servidor', e);
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      logger.error('Error de red al insertar planta', e);
      // Guardar localmente para sincronizar después
      try {
        final plantModel = PlantModel.fromEntity(plant);
        await localDataSource.insertPlant(plantModel);
        return const Right(null);
      } catch (_) {
        return Left(ConnectionFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado en insertPlant', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePlant(Plant plant) async {
    try {
      final plantModel = PlantModel.fromEntity(plant);
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        await remoteDataSource.updatePlant(plantModel);
      }

      await localDataSource.updatePlant(plantModel);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado en updatePlant', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlant(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        await remoteDataSource.deletePlant(id);
      }

      await localDataSource.deletePlant(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado en deletePlant', e);
      return Left(UnknownFailure(e.toString()));
    }
  }
}
