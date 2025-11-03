import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// Caso de uso: Obtener reportes con paginación
class GetReports {
  final ReportRepository repository;

  GetReports(this.repository);

  Future<Either<Failure, List<Report>>> call({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.getAllReports(page: page, pageSize: pageSize);
  }
}

/// Caso de uso: Obtener reportes por planta
class GetReportsByPlant {
  final ReportRepository repository;

  GetReportsByPlant(this.repository);

  Future<Either<Failure, List<Report>>> call(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.getReportsByPlant(
      plantId,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Caso de uso: Sincronizar reportes pendientes
class SyncPendingReports {
  final ReportRepository repository;

  SyncPendingReports(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.syncPendingReports();
  }
}
