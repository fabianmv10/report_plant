import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plant.dart';

/// Repositorio abstracto para operaciones con plantas
abstract class PlantRepository {
  /// Obtener todas las plantas
  Future<Either<Failure, List<Plant>>> getAllPlants();

  /// Obtener planta por ID
  Future<Either<Failure, Plant>> getPlantById(String id);

  /// Insertar nueva planta
  Future<Either<Failure, void>> insertPlant(Plant plant);

  /// Actualizar planta
  Future<Either<Failure, void>> updatePlant(Plant plant);

  /// Eliminar planta
  Future<Either<Failure, void>> deletePlant(String id);
}
