// lib/services/export_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

class ExportService {
  // Exportar a CSV
  static Future<void> exportReportsToCSV() async {
    final success = await DatabaseHelper.instance.exportReportsToCSV();
    
    if (!success) {
      // Manejar error
      return;
    }
    
    // Lógica para compartir el archivo CSV
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/reportes_turno.csv';
    final file = File(path);
    
    if (await file.exists()) {
      await Share.shareXFiles([XFile(path)], text: 'Reportes de Turno');
    }
  }
  
  // Exportar a JSON
  static Future<void> exportReportsToJSON() async {
    final success = await DatabaseHelper.instance.exportReportsToJSON();
    
    if (!success) {
      // Manejar error
      return;
    }
    
    // Lógica para compartir el archivo JSON
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/reportes_turno.json';
    final file = File(path);
    
    if (await file.exists()) {
      await Share.shareXFiles([XFile(path)], text: 'Reportes de Turno');
    }
  }
}