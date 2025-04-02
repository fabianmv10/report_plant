import 'dart:math';
import '../models/report.dart';
import '../models/report_extension.dart';

/// Servicio para generar y analizar métricas de producción
class MetricsService {
  /// Calcular métricas consolidadas para un grupo de reportes
  static Map<String, dynamic> calculateConsolidatedMetrics(List<Report> reports) {
    if (reports.isEmpty) {
      return {
        'cantidad_total': 0.0,
        'eficiencia_promedio': 0.0,
        'unidades_procesadas': 0,
        'reportes_totales': 0,
        'tendencia': 0.0,
      };
    }
    
    double totalQuantity = 0.0;
    double totalEfficiency = 0.0;
    int totalUnits = 0;
    
    for (final report in reports) {
      final metrics = report.generateMetrics();
      totalQuantity += metrics['cantidad_total'] as double;
      totalEfficiency += metrics['eficiencia'] as double;
      totalUnits += (metrics['unidades_procesadas'] as double).round();
    }
    
    // Calcular tendencia comparando con datos anteriores (simulado)
    final tendencia = _calculateTrend(reports);
    
    return {
      'cantidad_total': totalQuantity,
      'eficiencia_promedio': totalEfficiency / reports.length,
      'unidades_procesadas': totalUnits,
      'reportes_totales': reports.length,
      'tendencia': tendencia,
    };
  }
  
  /// Calcular métricas por turno
  static Map<String, Map<String, dynamic>> calculateMetricsByShift(List<Report> reports) {
    final metricsByShift = <String, Map<String, dynamic>>{};
    final shifts = ['Mañana', 'Tarde', 'Noche'];
    
    for (final shift in shifts) {
      final shiftReports = reports.where((r) => r.shift == shift).toList();
      metricsByShift[shift] = calculateConsolidatedMetrics(shiftReports);
    }
    
    return metricsByShift;
  }
  
  /// Calcular tendencia comparando con periodos anteriores
  static double _calculateTrend(List<Report> reports) {
    if (reports.isEmpty) return 0.0;
    
    // Ordenar reportes por fecha (más recientes primero)
    reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Si hay reportes de diferentes días, podríamos analizar tendencia entre días
    final latestDate = reports.first.timestamp;
    final previousReports = reports.where(
      (r) => r.timestamp.difference(latestDate).inHours < -24
    ).toList();
    
    if (previousReports.isEmpty) {
      // Si no hay datos anteriores, usar una tendencia simulada
      return (Random().nextDouble() * 10) - 5; // Entre -5% y +5%
    }
    
    // Calcular cantidades totales para los dos períodos
    final currentReports = reports.where(
      (r) => r.timestamp.difference(latestDate).inHours >= -24
    ).toList();
    
    double currentTotal = 0;
    double previousTotal = 0;
    
    for (final report in currentReports) {
      currentTotal += report.calculateTotalQuantity();
    }
    
    for (final report in previousReports) {
      previousTotal += report.calculateTotalQuantity();
    }
    
    if (previousTotal == 0) return 0.0;
    
    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }
  
  /// Calcular rendimiento por turno (kg/hora o l/hora)
  static Map<String, double> calculateProductionRate(List<Report> reports) {
    final productionRates = <String, double>{};
    final shifts = ['Mañana', 'Tarde', 'Noche'];
    
    // Duración estándar de cada turno en horas
    const Map<String, int> shiftDurations = {
      'Mañana': 8,
      'Tarde': 8,
      'Noche': 8,
    };
    
    for (final shift in shifts) {
      final shiftReports = reports.where((r) => r.shift == shift).toList();
      
      if (shiftReports.isEmpty) {
        productionRates[shift] = 0.0;
        continue;
      }
      
      double totalQuantity = 0.0;
      for (final report in shiftReports) {
        totalQuantity += report.calculateTotalQuantity();
      }
      
      // Dividir por el número de reportes para evitar acumulación de múltiples días
      if (shiftReports.isNotEmpty) {
        totalQuantity = totalQuantity / shiftReports.length;
      }
      
      // Calcular tasa de producción por hora
      final hours = shiftDurations[shift] ?? 8;
      final rate = totalQuantity / hours;
      
      productionRates[shift] = rate;
    }
    
    return productionRates;
  }
  
  /// Generar datos para gráfico de producción por turno
  static List<Map<String, dynamic>> generateProductionChartData(List<Report> reports) {
    if (reports.isEmpty) return [];
    
    // Agrupar reportes por fecha
    final reportsByDate = <DateTime, List<Report>>{};
    
    for (final report in reports) {
      final date = DateTime(
        report.timestamp.year,
        report.timestamp.month,
        report.timestamp.day,
      );
      
      if (!reportsByDate.containsKey(date)) {
        reportsByDate[date] = [];
      }
      
      reportsByDate[date]!.add(report);
    }
    
    // Convertir a formato para gráfico
    final chartData = <Map<String, dynamic>>[];
    
    reportsByDate.forEach((date, dateReports) {
      final metricsByShift = calculateMetricsByShift(dateReports);
      
      chartData.add({
        'date': date,
        'Mañana': metricsByShift['Mañana']?['cantidad_total'] ?? 0.0,
        'Tarde': metricsByShift['Tarde']?['cantidad_total'] ?? 0.0,
        'Noche': metricsByShift['Noche']?['cantidad_total'] ?? 0.0,
        'Total': dateReports.fold<double>(
          0.0, 
          (sum, report) => sum + report.calculateTotalQuantity()
        ),
      });
    });
    
    // Ordenar por fecha
    chartData.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    return chartData;
  }
  
  /// Generar datos para gráfico de eficiencia por turno
  static List<Map<String, dynamic>> generateEfficiencyChartData(List<Report> reports) {
    if (reports.isEmpty) return [];
    
    // Agrupar reportes por fecha
    final reportsByDate = <DateTime, List<Report>>{};
    
    for (final report in reports) {
      final date = DateTime(
        report.timestamp.year,
        report.timestamp.month,
        report.timestamp.day,
      );
      
      if (!reportsByDate.containsKey(date)) {
        reportsByDate[date] = [];
      }
      
      reportsByDate[date]!.add(report);
    }
    
    // Convertir a formato para gráfico
    final chartData = <Map<String, dynamic>>[];
    
    reportsByDate.forEach((date, dateReports) {
      final efficiencyByShift = <String, double>{};
      
      // Calcular eficiencia por turno
      for (final shift in ['Mañana', 'Tarde', 'Noche']) {
        final shiftReports = dateReports.where((r) => r.shift == shift).toList();
        
        if (shiftReports.isEmpty) {
          efficiencyByShift[shift] = 0.0;
          continue;
        }
        
        double totalEfficiency = 0.0;
        for (final report in shiftReports) {
          totalEfficiency += report.calculateEfficiency();
        }
        
        efficiencyByShift[shift] = totalEfficiency / shiftReports.length;
      }
      
      // Calcular eficiencia promedio del día
      double avgEfficiency = 0.0;
      if (dateReports.isNotEmpty) {
        for (final report in dateReports) {
          avgEfficiency += report.calculateEfficiency();
        }
        avgEfficiency /= dateReports.length;
      }
      
      chartData.add({
        'date': date,
        'Mañana': efficiencyByShift['Mañana'] ?? 0.0,
        'Tarde': efficiencyByShift['Tarde'] ?? 0.0,
        'Noche': efficiencyByShift['Noche'] ?? 0.0,
        'Promedio': avgEfficiency,
      });
    });
    
    // Ordenar por fecha
    chartData.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    return chartData;
  }
}