import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// Caso de uso: Crear un nuevo reporte
class CreateReport {
  final ReportRepository repository;
  final Uuid uuid;

  CreateReport(this.repository, this.uuid);

  Future<Either<Failure, void>> call({
    required DateTime timestamp,
    required String leader,
    required String shift,
    required dynamic plant, // Puede ser Plant de la nueva entidad
    required Map<String, dynamic> data,
    String? notes,
  }) async {
    // Generar ID único con UUID
    final id = uuid.v4();

    final report = Report(
      id: id,
      timestamp: timestamp,
      leader: leader,
      shift: shift,
      plant: plant,
      data: data,
      notes: notes,
      synced: false,
    );

    return await repository.insertReport(report);
  }
}
