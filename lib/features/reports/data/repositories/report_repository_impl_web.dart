import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

/// Implementación del repositorio de reportes para WEB
/// Solo usa datasource remoto (sin cache local)
class ReportRepositoryImplWeb implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImplWeb({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Report>>> getAllReports({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final reports = await remoteDataSource.getAllReports(
        page: page,
        pageSize: pageSize,
      );
      return Right(reports.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      logger.error('Error del servidor al obtener reportes', e);
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      logger.error('Error de red al obtener reportes', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      logger.error('Error inesperado al obtener reportes', e);
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final report = await remoteDataSource.getReportById(id);
      return Right(report.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getReportsByPlant(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final reports = await remoteDataSource.getReportsByPlant(
        plantId,
        page: page,
        pageSize: pageSize,
      );
      return Right(reports.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> insertReport(Report report) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      // En web, insertar directamente al servidor (sin cache local)
      await remoteDataSource.insertReport(report.toModel());
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReport(Report report) async {
    return const Left(CacheFailure('Operación no soportada en web'));
  }

  @override
  Future<Either<Failure, void>> deleteReport(String id) async {
    return const Left(CacheFailure('Operación no soportada en web'));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncPendingReports() async {
    // En web no hay reportes pendientes (todo va directamente al servidor)
    return const Right({
      'success': true,
      'syncedCount': 0,
      'failedCount': 0,
      'totalCount': 0,
    });
  }
}
