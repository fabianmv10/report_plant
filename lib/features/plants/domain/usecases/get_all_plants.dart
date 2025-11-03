import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

/// Caso de uso: Obtener todas las plantas
class GetAllPlants {
  final PlantRepository repository;

  GetAllPlants(this.repository);

  Future<Either<Failure, List<Plant>>> call() async {
    return await repository.getAllPlants();
  }
}
