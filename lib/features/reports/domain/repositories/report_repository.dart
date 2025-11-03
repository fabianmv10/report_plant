import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/report.dart';

/// Repositorio abstracto para operaciones con reportes
abstract class ReportRepository {
  /// Obtener todos los reportes con paginación
  Future<Either<Failure, List<Report>>> getAllReports({
    int page = 1,
    int pageSize = 20,
  });

  /// Obtener reporte por ID
  Future<Either<Failure, Report>> getReportById(String id);

  /// Obtener reportes por planta
  Future<Either<Failure, List<Report>>> getReportsByPlant(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  });

  /// Obtener reportes por rango de fechas
  Future<Either<Failure, List<Report>>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int pageSize = 20,
  });

  /// Insertar nuevo reporte
  Future<Either<Failure, void>> insertReport(Report report);

  /// Actualizar reporte
  Future<Either<Failure, void>> updateReport(Report report);

  /// Eliminar reporte
  Future<Either<Failure, void>> deleteReport(String id);

  /// Sincronizar reportes pendientes
  Future<Either<Failure, Map<String, dynamic>>> syncPendingReports();

  /// Exportar reportes a CSV
  Future<Either<Failure, String>> exportReportsToCSV();

  /// Exportar reportes a JSON
  Future<Either<Failure, String>> exportReportsToJSON();
}
