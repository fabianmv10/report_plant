import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/report_model.dart';

/// Fuente de datos remota para reportes (API)
abstract class ReportRemoteDataSource {
  Future<List<ReportModel>> getAllReports({int page = 1, int pageSize = 20});
  Future<ReportModel> getReportById(String id);
  Future<List<ReportModel>> getReportsByPlant(String plantId, {int page = 1, int pageSize = 20});
  Future<void> insertReport(ReportModel report);
  Future<void> updateReport(ReportModel report);
  Future<void> deleteReport(String id);
  Future<Map<String, dynamic>> syncPendingReports(List<ReportModel> reports);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient dioClient;

  ReportRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ReportModel>> getAllReports({int page = 1, int pageSize = 20}) async {
    try {
      final response = await dioClient.instance.get(
        '/reports',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => ReportModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          'Error al obtener reportes',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en getAllReports', e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Tiempo de espera agotado');
      }
      throw ServerException(e.message ?? 'Error de servidor');
    } catch (e) {
      logger.error('Error inesperado en getAllReports', e);
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<ReportModel> getReportById(String id) async {
    try {
      final response = await dioClient.instance.get('/reports/$id');

      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al obtener reporte',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en getReportById', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<List<ReportModel>> getReportsByPlant(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dioClient.instance.get(
        '/reports',
        queryParameters: {
          'plantId': plantId,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => ReportModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          'Error al obtener reportes por planta',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en getReportsByPlant', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<void> insertReport(ReportModel report) async {
    try {
      final response = await dioClient.instance.post(
        '/reports',
        data: report.toJson(),
      );

      if (response.statusCode != 201) {
        throw ServerException(
          'Error al insertar reporte',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en insertReport', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    try {
      final response = await dioClient.instance.put(
        '/reports/${report.id}',
        data: report.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Error al actualizar reporte',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en updateReport', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      final response = await dioClient.instance.delete('/reports/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Error al eliminar reporte',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      logger.error('Error en deleteReport', e);
      throw NetworkException(e.message ?? 'Error de conexión');
    }
  }

  @override
  Future<Map<String, dynamic>> syncPendingReports(List<ReportModel> reports) async {
    try {
      int successCount = 0;
      int failedCount = 0;

      for (var report in reports) {
        try {
          await insertReport(report);
          successCount++;
        } catch (e) {
          logger.error('Error sincronizando reporte ${report.id}', e);
          failedCount++;
        }
      }

      return {
        'success': true,
        'syncedCount': successCount,
        'failedCount': failedCount,
        'totalCount': reports.length,
      };
    } catch (e) {
      logger.error('Error en syncPendingReports', e);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
