// lib/services/export_service.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

class ExportService {
  // Exportar a CSV
  static Future<void> exportReportsToCSV() async {
    try {
      // Obtener los datos en formato CSV
      final csvData = await DatabaseHelper.instance.exportReportsToCSV();
      
      if (csvData == null) {
        throw Exception('No se pudieron obtener los datos CSV');
      }
      
      // Guardar el contenido en un archivo temporal
      final directory = await getTemporaryDirectory(); // Usar directorio temporal en lugar de externo
      final path = '${directory.path}/reportes_turno.csv';
      final file = File(path);
      
      // Escribir los datos al archivo
      await file.writeAsBytes(utf8.encode(csvData));
      
      // Compartir el archivo
      await Share.shareXFiles([XFile(path)], text: 'Reportes de Turno (CSV)');
    } catch (e) {
      print('Error al exportar a CSV: $e');
      // Aquí podrías implementar un mecanismo para mostrar el error al usuario
    }
  }
  
  // Exportar a JSON
  static Future<void> exportReportsToJSON() async {
    try {
      // Obtener los datos en formato JSON
      final jsonData = await DatabaseHelper.instance.exportReportsToJSON();
      
      if (jsonData == null) {
        throw Exception('No se pudieron obtener los datos JSON');
      }
      
      // Guardar el contenido en un archivo temporal
      final directory = await getTemporaryDirectory(); // Usar directorio temporal en lugar de externo
      final path = '${directory.path}/reportes_turno.json';
      final file = File(path);
      
      // Escribir los datos al archivo
      await file.writeAsBytes(utf8.encode(jsonData));
      
      // Compartir el archivo
      await Share.shareXFiles([XFile(path)], text: 'Reportes de Turno (JSON)');
    } catch (e) {
      print('Error al exportar a JSON: $e');
      // Aquí podrías implementar un mecanismo para mostrar el error al usuario
    }
  }
}