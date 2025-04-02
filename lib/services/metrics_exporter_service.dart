// lib/services/metrics_exporter_service.dart
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../models/report.dart';
import '../models/report_extension.dart';

/// Servicio para exportar métricas a diferentes formatos
class MetricsExporterService {
  /// Exportar métricas a CSV
  static Future<void> exportMetricsToCSV(List<Report> reports, DateTime date) async {
    if (reports.isEmpty) return;
    
    // Formatear fecha para el nombre del archivo
    final dateStr = DateFormat('yyyyMMdd').format(date);
    
    // Crear encabezados
    List<List<dynamic>> rows = [
      [
        'Fecha', 'Turno', 'Líder', 'Planta', 'Referencia', 
        'Unidades', 'Cantidad (kg/l)', 'Eficiencia (%)', 'Novedades'
      ]
    ];
    
    // Agrupar por planta
    final reportsByPlant = <String, List<Report>>{};
    for (final report in reports) {
      reportsByPlant.putIfAbsent(report.plant.name, () => []).add(report);
    }
    
    // Agregar datos por planta
    reportsByPlant.forEach((plantName, plantReports) {
      // Encabezado de planta
      rows.add([plantName, '', '', '', '', '', '', '', '']);
      
      // Datos de cada reporte
      for (final report in plantReports) {
        final metrics = report.generateMetrics();
        final referencia = report.getString('referencia');
        final unidades = metrics['unidades_procesadas'] as double;
        
        rows.add([
          DateFormat('dd/MM/yyyy').format(report.timestamp),
          report.shift,
          report.leader,
          plantName,
          referencia,
          unidades.round().toString(),
          metrics['cantidad_total'].toStringAsFixed(2),
          metrics['eficiencia'].toStringAsFixed(2),
          report.notes ?? '',
        ]);
      }
      
      // Agregar fila vacía entre plantas
      rows.add(['', '', '', '', '', '', '', '', '']);
    });
    
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
    final path = '${directory?.path}/metricas_produccion_$dateStr.csv';
    final file = File(path);

    // Escribir BOM seguido del contenido
    final completeData = [...bom, ...utf8.encode(csv)];
    await file.writeAsBytes(completeData);
    
    // Compartir archivo
    await Share.shareXFiles([XFile(path)], text: 'Métricas de Producción - ${DateFormat('dd/MM/yyyy').format(date)}');
  }
  
  /// Exportar métricas a JSON
  static Future<void> exportMetricsToJSON(List<Report> reports, DateTime date) async {
    if (reports.isEmpty) return;
    
    // Formatear fecha para el nombre del archivo
    final dateStr = DateFormat('yyyyMMdd').format(date);
    
    // Estructura para datos exportados
    final exportData = {
      'fecha': DateFormat('yyyy-MM-dd').format(date),
      'plantas': <Map<String, dynamic>>[],
    };
    
    // Agrupar por planta
    final reportsByPlant = <String, List<Report>>{};
    for (final report in reports) {
      reportsByPlant.putIfAbsent(report.plant.name, () => []).add(report);
    }
    
    // Procesar cada planta
    reportsByPlant.forEach((plantName, plantReports) {
      final List<Map<String, dynamic>> reportsList = [];
      final plantData = {
        'nombre': plantName,
        'reportes': reportsList,
        'metricas_consolidadas': <String, dynamic>{},
      };
      
      // Procesar reportes individuales
      // ignore: unused_local_variable
      for (final report in plantReports) {
        final metrics = report.generateMetrics();
        
        reportsList.add({
          'id': report.id,
          'fecha': DateFormat('yyyy-MM-dd HH:mm').format(report.timestamp),
          'turno': report.shift,
          'lider': report.leader,
          'metricas': {
            'cantidad_total': metrics['cantidad_total'],
            'eficiencia': metrics['eficiencia'],
            'unidades_procesadas': metrics['unidades_procesadas'],
          },
          'datos': report.data,
          'novedades': report.notes,
        });
      }
      
      // Calcular métricas consolidadas
      double totalQuantity = 0;
      double totalEfficiency = 0;
      int totalUnits = 0;
      
      for (final report in plantReports) {
        final metrics = report.generateMetrics();
        totalQuantity += metrics['cantidad_total'] as double;
        totalEfficiency += metrics['eficiencia'] as double;
        totalUnits += (metrics['unidades_procesadas'] as double).round();
      }
      
      plantData['metricas_consolidadas'] = {
        'cantidad_total': totalQuantity,
        'eficiencia_promedio': totalEfficiency / plantReports.length,
        'unidades_procesadas': totalUnits,
      };
      
      (exportData['plantas'] as List<Map<String, dynamic>>).add(plantData);
    });
    
    // Convertir a JSON
    final jsonData = jsonEncode(exportData);
    
    // Guardar archivo
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/metricas_produccion_$dateStr.json';
    final file = File(path);
    await file.writeAsString(jsonData);
    
    // Compartir archivo
    await Share.shareXFiles([XFile(path)], text: 'Métricas de Producción - ${DateFormat('dd/MM/yyyy').format(date)}');
  }
  
  /// Exportar resumen de métricas en formato de texto plano
  static Future<void> exportMetricsSummary(List<Report> reports, DateTime date) async {
    if (reports.isEmpty) return;
    
    // Formatear fecha para el nombre del archivo
    final dateStr = DateFormat('yyyyMMdd').format(date);
    
    // Crear cabecera del informe
    StringBuffer summaryText = StringBuffer();
    summaryText.writeln('RESUMEN DE PRODUCCIÓN - ${DateFormat('dd/MM/yyyy').format(date)}');
    summaryText.writeln('=============================================');
    summaryText.writeln();
    
    // Agrupar por planta
    final reportsByPlant = <String, List<Report>>{};
    for (final report in reports) {
      reportsByPlant.putIfAbsent(report.plant.name, () => []).add(report);
    }
    
    // Totales generales
    double grandTotalQuantity = 0;
    int grandTotalUnits = 0;
    
    // Procesar cada planta
    reportsByPlant.forEach((plantName, plantReports) {
      summaryText.writeln('PLANTA: $plantName');
      summaryText.writeln('------------------------------------------');
      
      // Calcular métricas consolidadas por planta
      double totalQuantity = 0;
      double totalEfficiency = 0;
      int totalUnits = 0;
      
      for (final report in plantReports) {
        final metrics = report.generateMetrics();
        totalQuantity += metrics['cantidad_total'] as double;
        totalEfficiency += metrics['eficiencia'] as double;
        totalUnits += (metrics['unidades_procesadas'] as double).round();
      }
      
      // Acumular totales generales
      grandTotalQuantity += totalQuantity;
      grandTotalUnits += totalUnits;
      
      // Resumen de la planta
      summaryText.writeln('Cantidad Total: ${totalQuantity.toStringAsFixed(2)} kg/l');
      summaryText.writeln('Unidades Procesadas: $totalUnits');
      summaryText.writeln('Eficiencia Promedio: ${(totalEfficiency / plantReports.length).toStringAsFixed(2)}%');
      summaryText.writeln();
      
      // Resumen por turno
      summaryText.writeln('Desglose por Turno:');
      
      for (final shift in ['Mañana', 'Tarde', 'Noche']) {
        final shiftReports = plantReports.where((r) => r.shift == shift).toList();
        
        if (shiftReports.isEmpty) continue;
        
        double shiftQuantity = 0;
        double shiftEfficiency = 0;
        int shiftUnits = 0;
        
        for (final report in shiftReports) {
          final metrics = report.generateMetrics();
          shiftQuantity += metrics['cantidad_total'] as double;
          shiftEfficiency += metrics['eficiencia'] as double;
          shiftUnits += (metrics['unidades_procesadas'] as double).round();
        }
        
        summaryText.writeln('  - $shift:');
        summaryText.writeln('    Cantidad: ${shiftQuantity.toStringAsFixed(2)} kg/l');
        summaryText.writeln('    Unidades: $shiftUnits');
        summaryText.writeln('    Eficiencia: ${(shiftEfficiency / shiftReports.length).toStringAsFixed(2)}%');
        
        // Agregar líderes
        summaryText.write('    Lideres: ');
        summaryText.writeln(shiftReports.map((r) => r.leader).toSet().join(', '));
        
        // Agregar novedades si existen
        final novedades = shiftReports
            .where((r) => r.notes != null && r.notes!.isNotEmpty)
            .map((r) => r.notes)
            .join(' | ');
            
        if (novedades.isNotEmpty) {
          summaryText.writeln('    Novedades: $novedades');
        }
        
        summaryText.writeln();
      }
      
      summaryText.writeln('=============================================');
      summaryText.writeln();
    });
    
    // Agregar resumen general
    summaryText.writeln('RESUMEN GENERAL:');
    summaryText.writeln('Producción Total: ${grandTotalQuantity.toStringAsFixed(2)} kg/l');
    summaryText.writeln('Unidades Totales: $grandTotalUnits');
    summaryText.writeln();
    summaryText.writeln('Informe generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    
    // Guardar archivo
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/resumen_produccion_$dateStr.txt';
    final file = File(path);
    await file.writeAsString(summaryText.toString());
    
    // Compartir archivo
    await Share.shareXFiles([XFile(path)], text: 'Resumen de Producción - ${DateFormat('dd/MM/yyyy').format(date)}');
  }
}