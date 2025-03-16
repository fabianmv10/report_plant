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
      ['ID', 'Fecha', 'Operador', 'Turno', 'Planta', 'Datos', 'Novedades']
    ];
    
    // Agregar datos
    for (final report in reports) {
      rows.add([
        report.id,
        report.timestamp.toIso8601String(),
        report.operator,
        report.shift,
        report.plant.name,
        jsonEncode(report.data),
        report.notes
      ]);
    }
    
    // Convertir a CSV
    String csv = const ListToCsvConverter().convert(rows);
    
    // Guardar archivo
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/reportes_turno.csv';
    final file = File(path);
    await file.writeAsString(csv);
    
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