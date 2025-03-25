import '../models/report.dart';

class ProductionGoals {
  // Obtener metas de producción para una planta específica
  static Map<String, double> getGoalsForPlant(String plantId) {
    final goals = <String, double>{};
    
    // Configurar metas específicas para cada planta según su ID
    switch (plantId) {
      case '1': 
        goals['produccion_stas_1ra_reaccion'] = 150;
        goals['produccion_stas_2da_reaccion'] = 150;
        break;
      case '2':
        goals['produccion_stbs'] = 200;
        goals['produccion_stbl'] = 40000;
        break;
      case '3':
        goals['produccion'] = 220;
        break;
      case '4':
        goals['produccion'] = 11000;
        break;
      case '5':
        goals['produccion'] = 11000;
        break;
      case '6':
        goals['produccion_cloal'] = 5300;
        goals['produccion_pac'] = 4300;
        break;
      case '7':
        goals['produccion'] = 5000;
        break;
      case '8':
        goals['produccion_ultrabond_dc'] = 5200;
        goals['produccion_ultrabond_4010'] = 5000;
        break;
      case '9':
        goals['unidades'] = 30;
        break;
    }
    return goals;
  }
}

/// Clase para manejar el cálculo de métricas para cada planta
class PlantMetrics {
  
  /// Calcular la producción total para un reporte
  /// Suma todos los campos que se relacionan con producción o cantidad
  static double calculateTotalProduction(Report report) {
    double total = 0;
    
    report.data.forEach((key, value) {
      // Incluir campos relacionados con producción o cantidad
      if (key.contains('produccion') ||
          key.contains('unidades')) {
        total += report.getNumeric(key);
      }
    });
    
    return total;
  }
  
  /// Calcular el cumplimiento de metas para un reporte
  /// Compara producción real vs metas establecidas
  static double calculateCompliance(Report report, Map<String, double> goals) {
    double totalActual = 0;
    double totalGoal = 0;
    
    report.data.forEach((key, value) {
      if (goals.containsKey(key)) {
        double actual = report.getNumeric(key);
        double goal = goals[key] ?? 0;
        
        totalActual += actual;
        totalGoal += goal;
      }
    });
    
    if (totalGoal <= 0) return 0;
    
    // Calcular porcentaje de cumplimiento
    double compliance = (totalActual / totalGoal) * 100;
    
    // Limitar a 0-120% (permitir sobrecumplimiento hasta 120%)
    return compliance < 0 ? 0 : (compliance > 120 ? 120 : compliance);
  }
  
  /// Calcular cumplimiento por campo específico
  static Map<String, double> calculateFieldCompliance(Report report, Map<String, double> goals) {
    final fieldCompliance = <String, double>{};
    
    goals.forEach((key, goalValue) {
      if (goalValue > 0 && report.data.containsKey(key)) {
        double actualValue = report.getNumeric(key);
        double compliance = (actualValue / goalValue) * 100;
        // Limitar a 0-120%
        compliance = compliance < 0 ? 0 : (compliance > 120 ? 120 : compliance);
        fieldCompliance[key] = compliance;
      }
    });
    
    return fieldCompliance;
  }
  
  /// Obtener el color para un valor de KPI según rangos estándar
  static int getKpiColor(double value) {
    if (value >= 90) return 0xFF388E3C; // Verde (success)
    if (value >= 75) return 0xFFF57C00; // Naranja (warning)
    return 0xFFD32F2F; // Rojo (error)
  }
  
  /// Calcular un promedio de las métricas para un conjunto de reportes
  static Map<String, double> calculateAverageMetrics(List<Report> reports) {
    if (reports.isEmpty) {
      return {
        'compliance': 0,
        'production': 0,
      };
    }
    
    double totalCompliance = 0;
    double totalProduction = 0;
    
    for (var report in reports) {
      final goals = getGoalsForPlant(report.plant.id);
      
      totalCompliance += calculateCompliance(report, goals);
      totalProduction += calculateTotalProduction(report);
    }
    
    return {
      'compliance': totalCompliance / reports.length,
      'production': totalProduction,
    };
  }

  /// Método helper para obtener las metas para una planta
  static Map<String, double> getGoalsForPlant(String plantId) {
    return ProductionGoals.getGoalsForPlant(plantId);
  }
}