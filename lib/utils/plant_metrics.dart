import '../models/report.dart';

/// Clase para manejar el cálculo de métricas para cada planta
class PlantMetrics {
  /// Calcular la producción total para un reporte
  /// Suma todos los campos que se relacionan con producción o cantidad
  static double calculateTotalProduction(Report report) {
    double total = 0;
    
    report.data.forEach((key, value) {
      // Incluir campos relacionados con producción o cantidad
      if (key.contains('produccion') || 
          key.contains('cantidad') || 
          key.contains('unidades') ||
          key.contains('reaccion')) {
        total += report.getNumeric(key);
      }
    });
    
    return total;
  }
  
  /// Calcular la eficiencia para un reporte específico
  /// La eficiencia depende del tipo de planta
  static double calculateEfficiency(Report report) {
    double efficiency = 0;
    
    // Calcular según tipo de planta
    switch (report.plant.id) {
      case '1': // Sulfato de Aluminio Tipo A
        double firstReaction = report.getNumeric('produccion_primera_reaccion');
        double secondReaction = report.getNumeric('produccion_segunda_reaccion');
        
        if (firstReaction > 0 && secondReaction > 0) {
          // Eficiencia basada en balance de reacciones - valor óptimo cercano a 1:1
          double ratio = firstReaction / (secondReaction > 0 ? secondReaction : 1);
          efficiency = 60 + (ratio > 0.9 && ratio < 1.1 ? 30 : 20);
        } else {
          efficiency = 70; // Valor predeterminado
        }
        break;


      case '2': // Sulfato de Aluminio Tipo B
        // Para sulfatos, considerar relación entre producción primer/segunda reacción
        double firstReaction = report.getNumeric('produccion_primera_reaccion');
        double secondReaction = report.getNumeric('produccion_segunda_reaccion');
        
        if (firstReaction > 0 && secondReaction > 0) {
          // Eficiencia basada en balance de reacciones - valor óptimo cercano a 1:1
          double ratio = firstReaction / (secondReaction > 0 ? secondReaction : 1);
          efficiency = 60 + (ratio > 0.9 && ratio < 1.1 ? 30 : 20);
        } else {
          efficiency = 70; // Valor predeterminado
        }
        break;
        
      case '3': // Banalum
        // Eficiencia basada en producción de empaque
        double empaque = report.getNumeric('produccion_ban_empaque');
        efficiency = 70 + (empaque > 100 ? 20 : empaque / 5);
        break;
        
      case '4': // Bisulfito de Sodio
        // Eficiencia basada en pH y densidad
        double ph1 = report.getNumeric('ph_concentrador_1');
        double densidad1 = report.getNumeric('densidad_concentrador_1');
        
        // Valores óptimos: pH entre 4-7, densidad entre 1.2-1.35
        bool optimalPh = ph1 >= 4 && ph1 <= 7;
        bool optimalDensity = densidad1 >= 1.2 && densidad1 <= 1.35;
        
        if (optimalPh && optimalDensity) {
          efficiency = 90;
        } else if (optimalPh || optimalDensity) {
          efficiency = 80;
        } else {
          efficiency = 70;
        }
        break;
        
      case '5': // Silicatos
        // Eficiencia basada en Baume y presión
        double baume = report.getNumeric('baume');
        double presion = report.getNumeric('presion');
        
        // Valores óptimos dependen del tipo de silicato
        String referencia = report.getString('referencia').toLowerCase();
        
        double optimalBaume = 0;
        if (referencia.contains('p40')) {
          optimalBaume = 40;
        } else if (referencia.contains('s50')) {
          optimalBaume = 50;
        } else if (referencia.contains('k40')) {
          optimalBaume = 40;
        } else if (referencia.contains('k47')) {
          optimalBaume = 47;
        }
        
        // Cálculo de eficiencia
        double baumeDeviation = optimalBaume > 0 ? 
            (1 - ((baume - optimalBaume).abs() / optimalBaume)) : 1;
        
        // Rango óptimo de presión: 80-120 psi
        bool optimalPressure = presion >= 80 && presion <= 120;
        
        efficiency = 70 + (baumeDeviation * 20) + (optimalPressure ? 10 : 0);
        break;
        
      case '6': // Policloruro de Aluminio
        // Eficiencia basada en densidad del producto filtrado
        double densidad = report.getNumeric('densidad_producto_filtrado');
        
        // Valor óptimo: densidad entre 1.30-1.33
        bool optimalDensity = densidad >= 1.30 && densidad <= 1.33;
        
        efficiency = optimalDensity ? 90 : 75;
        break;
        
      case '7': // Polímeros Catiónicos
      case '8': // Polímeros Aniónicos
        // Eficiencia basada en pH y sólidos
        double pH = report.getNumeric('ph');
        double solidos = report.getNumeric('solidos');
        
        // Valores óptimos
        bool optimalPh = pH >= 3.5 && pH <= 5.5;
        bool optimalSolids = solidos >= 40 && solidos <= 60;
        
        if (optimalPh && optimalSolids) {
          efficiency = 90;
        } else if (optimalPh || optimalSolids) {
          efficiency = 80;
        } else {
          efficiency = 70;
        }
        break;
        
      case '9': // Llenados
        // Eficiencia basada en la cantidad de unidades
        double unidades = report.getNumeric('unidades');
        efficiency = 75 + (unidades > 20 ? 15 : unidades * 0.75);
        break;
        
      default:
        // Para otras plantas, valor estándar del 80%
        efficiency = 80;
    }
    
    // Limitar a rango 0-100%
    return efficiency < 0 ? 0 : (efficiency > 100 ? 100 : efficiency);
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
  
  /// Obtener el color para un valor de KPI según rangos estándar
  static int getKpiColor(double value) {
    if (value >= 90) return 0xFF388E3C; // Verde (success)
    if (value >= 75) return 0xFFF57C00; // Naranja (warning)
    return 0xFFD32F2F; // Rojo (error)
  }
  
  /// Calcular la tendencia comparando dos valores (positiva, negativa o neutral)
  static int calculateTrend(double current, double previous) {
    if (previous <= 0) return 0; // Neutral si no hay datos previos
    
    double change = current - previous;
    double percentChange = (change / previous) * 100;
    
    if (percentChange >= 5) return 1;  // Tendencia positiva (>5%)
    if (percentChange <= -5) return -1; // Tendencia negativa (<-5%)
    return 0; // Tendencia neutral (entre -5% y 5%)
  }
  
  /// Obtener metas de producción para una planta específica
  static Map<String, double> getProductionGoals(String plantId) {
    final goals = <String, double>{};
    
    // Configurar metas específicas para cada planta según su ID
    switch (plantId) {
      case '1': // Sulfato de Aluminio Tipo A
        goals['produccion_primera_reaccion'] = 100;
        goals['produccion_segunda_reaccion'] = 100;
        goals['produccion_liquida'] = 12000;
        break;
        
      case '2': // Sulfato de Aluminio Tipo B
        goals['produccion_stbs_empaque'] = 200;
        goals['produccion_stbl_tanque'] = 40000;
        break;
        
      case '3': // Banalum
        goals['produccion_ban_empaque'] = 180;
        break;
        
      case '4': // Bisulfito de Sodio
        goals['cantidad_trasiego'] = 10000;
        break;
        
      case '5': // Silicatos
        goals['cantidad'] = 10000;
        break;
        
      case '6': // Policloruro de Aluminio
        goals['cantidad_trasiego_tanque'] = 4000;
        goals['cantidad_producto_filtrado'] = 6000;
        break;
        
      case '7': // Polímeros Catiónicos
        goals['cantidad'] = 0.8;
        break;
        
      case '8': // Polímeros Aniónicos
        goals['cantidad'] = 0.8;
        break;
        
      case '9': // Llenados
        goals['unidades'] = 30;
        break;
    }
    
    return goals;
  }
  
  /// Calcular un promedio de las métricas para un conjunto de reportes
  static Map<String, double> calculateAverageMetrics(List<Report> reports) {
    if (reports.isEmpty) {
      return {
        'efficiency': 0,
        'compliance': 0,
        'production': 0,
      };
    }
    
    double totalEfficiency = 0;
    double totalCompliance = 0;
    double totalProduction = 0;
    
    for (var report in reports) {
      final goals = getProductionGoals(report.plant.id);
      
      totalEfficiency += calculateEfficiency(report);
      totalCompliance += calculateCompliance(report, goals);
      totalProduction += calculateTotalProduction(report);
    }
    
    return {
      'efficiency': totalEfficiency / reports.length,
      'compliance': totalCompliance / reports.length,
      'production': totalProduction,
    };
  }
}