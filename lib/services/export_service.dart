// lib/services/export_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'database_helper.dart';

class ExportService {
  // Exportar a CSV
  static Future<void> exportReportsToCSV() async {
    final reports = await DatabaseHelper.instance.getAllReports();
    
    // Crear encabezados
    List<List<dynamic>> rows = [
      ['ID', 'Fecha', 'Reportado por', 'Turno', 'Planta', 'Datos', 'Novedades'],
    ];
    
    // Agregar datos
    for (final report in reports) {
      rows.add([
        report.id,
        report.timestamp.toIso8601String(),
        report.leader,
        report.shift,
        report.plant.name,
        jsonEncode(report.data),
        report.notes,
      ]);
    }
    
    // Convertir a CSV
    String csv = const ListToCsvConverter(
      fieldDelimiter: ',',
      textDelimiter: '"',
      textEndDelimiter: '"',
      eol: '\n',
    ).convert(rows);

    // Añadir BOM (Byte Order Mark) para indicar que el archivo está en UTF-8
    final bom = utf8.encode('\uFEFF');
    
    // Guardar archivo
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/reportes_turno.csv';
    final file = File(path);

    // Escribir BOM seguido del contenido
    final completeData = [...bom, ...utf8.encode(csv)];
    await file.writeAsBytes(completeData);
    
    // Compartir archivo
    await Share.shareXFiles([XFile(path)], text: 'Reportes de Turno');
  }
  
  // Exportar a JSON
  static Future<void> exportReportsToJSON() async {
    final reports = await DatabaseHelper.instance.getAllReports();
    
    // Convertir a JSON
    final reportsList = reports.map((report) => report.toJson()).toList();
    final jsonData = jsonEncode(reportsList);
    
    // Guardar archivo
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/reportes_turno.json';
    final file = File(path);
    await file.writeAsString(jsonData);
    
    // Compartir archivo
    await Share.shareXFiles([XFile(path)], text: 'Reportes de Turno');
  }
}