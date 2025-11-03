import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/plant_model.dart';

/// Fuente de datos local para plantas (SQLite)
abstract class PlantLocalDataSource {
  Future<List<PlantModel>> getAllPlants();
  Future<PlantModel> getPlantById(String id);
  Future<void> insertPlant(PlantModel plant);
  Future<void> updatePlant(PlantModel plant);
  Future<void> deletePlant(String id);
  Future<void> cachePlants(List<PlantModel> plants);
}

class PlantLocalDataSourceImpl implements PlantLocalDataSource {
  final Database database;

  PlantLocalDataSourceImpl(this.database);

  @override
  Future<List<PlantModel>> getAllPlants() async {
    try {
      final result = await database.query('plants');
      return result.map((json) => PlantModel.fromJson(json)).toList();
    } catch (e) {
      logger.error('Error en getAllPlants local', e);
      throw CacheException('Error al obtener plantas del caché');
    }
  }

  @override
  Future<PlantModel> getPlantById(String id) async {
    try {
      final result = await database.query(
        'plants',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        throw CacheException('Planta no encontrada en caché');
      }

      return PlantModel.fromJson(result.first);
    } catch (e) {
      logger.error('Error en getPlantById local', e);
      throw CacheException('Error al obtener planta del caché');
    }
  }

  @override
  Future<void> insertPlant(PlantModel plant) async {
    try {
      await database.insert(
        'plants',
        plant.toJsonForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      logger.error('Error en insertPlant local', e);
      throw CacheException('Error al insertar planta en caché');
    }
  }

  @override
  Future<void> updatePlant(PlantModel plant) async {
    try {
      await database.update(
        'plants',
        plant.toJsonForDb(),
        where: 'id = ?',
        whereArgs: [plant.id],
      );
    } catch (e) {
      logger.error('Error en updatePlant local', e);
      throw CacheException('Error al actualizar planta en caché');
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    try {
      await database.delete(
        'plants',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      logger.error('Error en deletePlant local', e);
      throw CacheException('Error al eliminar planta del caché');
    }
  }

  @override
  Future<void> cachePlants(List<PlantModel> plants) async {
    try {
      final batch = database.batch();
      for (var plant in plants) {
        batch.insert(
          'plants',
          plant.toJsonForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      logger.error('Error en cachePlants', e);
      throw CacheException('Error al cachear plantas');
    }
  }
}
