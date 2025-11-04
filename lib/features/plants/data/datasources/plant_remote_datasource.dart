import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/plant_model.dart';

/// Fuente de datos remota para plantas (API)
abstract class PlantRemoteDataSource {
  Future<List<PlantModel>> getAllPlants();
  Future<PlantModel> getPlantById(String id);
  Future<void> insertPlant(PlantModel plant);
  Future<void> updatePlant(PlantModel plant);
  Future<void> deletePlant(String id);
}

class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  final DioClient dioClient;

  PlantRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<PlantModel>> getAllPlants() async {
    try {
      final response = await dioClient.instance.get<dynamic>('/plants');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => PlantModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          'Error al obtener plantas',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en getAllPlants', e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Tiempo de espera agotado');
      }
      throw ServerException(e.message ?? 'Error de servidor');
    } catch (e) {
      logger.error('Error inesperado en getAllPlants', e);
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<PlantModel> getPlantById(String id) async {
    try {
      final response = await dioClient.instance.get<dynamic>('/plants/$id');

      if (response.statusCode == 200) {
        return PlantModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al obtener planta',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en getPlantById', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<void> insertPlant(PlantModel plant) async {
    try {
      final response = await dioClient.instance.post<dynamic>(
        '/plants',
        data: plant.toJson(),
      );

      if (response.statusCode != 201) {
        throw ServerException(
          'Error al insertar planta',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en insertPlant', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<void> updatePlant(PlantModel plant) async {
    try {
      final response = await dioClient.instance.put<dynamic>(
        '/plants/${plant.id}',
        data: plant.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Error al actualizar planta',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en updatePlant', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    try {
      final response = await dioClient.instance.delete<dynamic>('/plants/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Error al eliminar planta',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en deletePlant', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }
}
