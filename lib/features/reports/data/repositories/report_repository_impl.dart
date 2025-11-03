import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';

/// Implementación del repositorio de reportes
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final ReportLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Report>>> getAllReports({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReports = await remoteDataSource.getAllReports(
            page: page,
            pageSize: pageSize,
          );

          // Cachear localmente
          if (page == 1) {
            await localDataSource.cacheReports(remoteReports);
          }

          final reports = remoteReports.map((model) => model.toEntity()).toList();
          return Right(reports);
        } on ServerException catch (e) {
          logger.warning('Error al obtener reportes remotos, usando caché', e);
          return _getReportsFromCache(page: page, pageSize: pageSize);
        } on NetworkException catch (e) {
          logger.warning('Error de red, usando caché', e);
          return _getReportsFromCache(page: page, pageSize: pageSize);
        }
      } else {
        logger.info('Sin conexión, usando caché local');
        return _getReportsFromCache(page: page, pageSize: pageSize);
      }
    } catch (e) {
      logger.error('Error inesperado en getAllReports', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Report>>> _getReportsFromCache({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final localReports = await localDataSource.getAllReports(
        page: page,
        pageSize: pageSize,
      );
      final reports = localReports.map((model) => model.toEntity()).toList();
      return Right(reports);
    } on CacheException catch (e) {
      logger.error('Error al obtener reportes del caché', e);
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReport = await remoteDataSource.getReportById(id);
          await localDataSource.insertReport(remoteReport);
          return Right(remoteReport.toEntity());
        } on ServerException catch (e) {
          logger.warning('Error al obtener reporte remoto, usando caché', e);
          return _getReportFromCache(id);
        }
      } else {
        return _getReportFromCache(id);
      }
    } catch (e) {
      logger.error('Error inesperado en getReportById', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, Report>> _getReportFromCache(String id) async {
    try {
      final localReport = await localDataSource.getReportById(id);
      return Right(localReport.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getReportsByPlant(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteReports = await remoteDataSource.getReportsByPlant(
            plantId,
            page: page,
            pageSize: pageSize,
          );

          if (page == 1) {
            // Solo cachear primera página
            await localDataSource.cacheReports(remoteReports);
          }

          final reports = remoteReports.map((model) => model.toEntity()).toList();
          return Right(reports);
        } on ServerException catch (e) {
          logger.warning('Error al obtener reportes por planta, usando caché', e);
          return _getReportsByPlantFromCache(plantId, page: page, pageSize: pageSize);
        }
      } else {
        return _getReportsByPlantFromCache(plantId, page: page, pageSize: pageSize);
      }
    } catch (e) {
      logger.error('Error inesperado en getReportsByPlant', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Report>>> _getReportsByPlantFromCache(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final localReports = await localDataSource.getReportsByPlant(
        plantId,
        page: page,
        pageSize: pageSize,
      );
      final reports = localReports.map((model) => model.toEntity()).toList();
      return Right(reports);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int pageSize = 20,
  }) async {
    // TODO: Implementar filtrado por fecha en datasources
    return const Left(UnknownFailure('No implementado aún'));
  }

  @override
  Future<Either<Failure, void>> insertReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Insertar en servidor
          await remoteDataSource.insertReport(reportModel);
          // Marcar como sincronizado
          final syncedModel = reportModel.copyWith(synced: true);
          await localDataSource.insertReport(syncedModel);
        } on NetworkException catch (e) {
          logger.warning('Sin conexión, guardando localmente', e);
          // Guardar como no sincronizado
          final unsyncedModel = reportModel.copyWith(synced: false);
          await localDataSource.insertReport(unsyncedModel);
        }
      } else {
        // Guardar localmente para sincronizar después
        final unsyncedModel = reportModel.copyWith(synced: false);
        await localDataSource.insertReport(unsyncedModel);
      }

      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error al insertar reporte en servidor', e);
      // Guardar localmente de todos modos
      try {
        final reportModel = ReportModel.fromEntity(report);
        final unsyncedModel = reportModel.copyWith(synced: false);
        await localDataSource.insertReport(unsyncedModel);
        return const Right(null);
      } catch (_) {
        return Left(ServerFailure(e.message, e.statusCode));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado en insertReport', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        await remoteDataSource.updateReport(reportModel);
        final syncedModel = reportModel.copyWith(synced: true);
        await localDataSource.updateReport(syncedModel);
      } else {
        final unsyncedModel = reportModel.copyWith(synced: false);
        await localDataSource.updateReport(unsyncedModel);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado en updateReport', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        await remoteDataSource.deleteReport(id);
      }

      await localDataSource.deleteReport(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado en deleteReport', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncPendingReports() async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(ConnectionFailure('Sin conexión para sincronizar'));
      }

      // Obtener reportes pendientes
      final pendingReports = await localDataSource.getPendingReports();

      if (pendingReports.isEmpty) {
        return Right({
          'success': true,
          'syncedCount': 0,
          'failedCount': 0,
          'totalCount': 0,
        });
      }

      logger.info('Sincronizando ${pendingReports.length} reportes pendientes');

      // Sincronizar
      final result = await remoteDataSource.syncPendingReports(pendingReports);

      // Marcar como sincronizados los exitosos
      final syncedCount = result['syncedCount'] as int;
      for (int i = 0; i < syncedCount && i < pendingReports.length; i++) {
        await localDataSource.markAsSynced(pendingReports[i].id);
      }

      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      logger.error('Error inesperado en syncPendingReports', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportReportsToCSV() async {
    try {
      final reportsResult = await getAllReports(pageSize: 1000);

      return reportsResult.fold(
        (failure) => Left(failure),
        (reports) {
          if (reports.isEmpty) {
            return const Left(ValidationFailure('No hay reportes para exportar'));
          }

          final csv = StringBuffer();
          csv.writeln('ID,Fecha,Líder,Turno,Planta,Notas');

          for (var report in reports) {
            final fecha = '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year}';
            final notas = report.notes?.replaceAll('"', '""') ?? '';
            csv.writeln(
              '"${report.id}","$fecha","${report.leader}","${report.shift}","${report.plant.name}","$notas"',
            );
          }

          return Right(csv.toString());
        },
      );
    } catch (e) {
      logger.error('Error exportando a CSV', e);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportReportsToJSON() async {
    try {
      final reportsResult = await getAllReports(pageSize: 1000);

      return reportsResult.fold(
        (failure) => Left(failure),
        (reports) {
          if (reports.isEmpty) {
            return const Left(ValidationFailure('No hay reportes para exportar'));
          }

          final jsonData = reports.map((report) => {
                'id': report.id,
                'timestamp': report.timestamp.millisecondsSinceEpoch,
                'leader': report.leader,
                'shift': report.shift,
                'plant_id': report.plant.id,
                'plant_name': report.plant.name,
                'data': report.data,
                'notes': report.notes,
              }).toList();

          return Right(jsonData.toString());
        },
      );
    } catch (e) {
      logger.error('Error exportando a JSON', e);
      return Left(UnknownFailure(e.toString()));
    }
  }
}
