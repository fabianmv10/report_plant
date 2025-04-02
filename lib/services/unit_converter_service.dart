import '../models/report.dart';

/// Servicio para convertir unidades a cantidades y calcular métricas
class UnitConverterService {
  // Mapa que contiene factores de conversión por referencia (producto)
  static final Map<String, double> _conversionFactors = {
    // Sulfato de Aluminio Tipo A
    'SATA x 25 Kg': 25.0,
    'SATA IF x 25 Kg': 25.0,
    'SATA IF x 1000 Kg': 1000.0,
    
    // Silicatos
    'Silicato Sodio P40': 1250.0,
    'Silicato Sodio S50': 1250.0,
    'Silicato Potasio K40': 1250.0,
    'Silicato Potasio K47': 1250.0,
    
    // Policloruro
    'Cloruro de Aluminio': 1000.0,
    'Ultrafloc 100': 1250.0,
    'Ultrafloc 200': 1200.0,
    'Ultrafloc 300': 1250.0,
    
    // Polímeros Catiónicos
    'Ultrabond 21032': 1050.0,
    'Ultrabond 23032': 1050.0,
    'Ultrabond 33005': 1000.0,
    'Ultrafloc 4001/Rapised A': 1000.0,
    'Ultrafloc 4002/Rapised B': 1100.0,
    'Ultrafloc 4010': 1000.0,
    
    // Polímeros Aniónicos
    'Ultrabond DC': 1000.0,
    'Ultrabond 4010': 1000.0,
    
    // Llenados (añadir factores de conversión para cada producto)
    'Acido Clorhidrico 200 Kg': 200.0,
    'Acido Clorhidrico 240 Kg': 240.0,
    'Acido Fos 34,6% H3PO4 1200 Kg': 1200.0,
    'Acido Fos 55% H3PO4 250 kg': 250.0,
    'Acido Fos 85% H3PO4 300 kg': 300.0,
    'Acido Sulfurico 200 Kg': 200.0,
    'Acido Sulfurico 250 Kg': 250.0,
    'Bisulfito de Sodio 250 Kg': 250.0,
    'Metasilicato de Sodio 250 Kg': 250.0,
    'Rapised 4050 1000 Kg': 1000.0,
    'Rapised A 250 Kg': 250.0,
    'Rapised A 1000 Kg': 1000.0,
    'Rapised B 250 Kg': 250.0,
    'Rapised B 1100 Kg': 1100.0,
    'Silicato F47 250 Kg': 250.0,
    'Silicato K40 250 Kg': 250.0,
    'Silicato K40 1250 Kg': 1250.0,
    'Silicato K47 250 Kg': 250.0,
    'Silicato P40 250 Kg': 250.0,
    'Silicato P40 1250 Kg': 1250.0,
    'Silicato S50 250 Kg': 250.0,
    'Sulfato Al TA 250 Kg': 250.0,
    'Sulfato Al TA 1250 Kg': 1250.0,
    'Sulfato Al TB 250 Kg': 250.0,
    'Sulfato Al TB 1300 Kg': 1300.0,
    'Ultrabond 21032 1050 Kg Exp': 1050.0,
    'Ultrabond 23032 1050 Kg Exp': 1050.0,
    'Ultrabond 4010 1000 Kg': 1000.0,
    'Ultrafloc 100 250 Kg': 250.0,
    'Ultrafloc 100 1250 Kg': 1250.0,
    'Ultrafloc 100 1300 Kg': 1300.0,
    'Ultrafloc 110 250 Kg': 250.0,
    'Ultrafloc 110 1250 Kg': 1250.0,
    'Ultrafloc 200 1200 Kg': 1200.0,
    'Ultrafloc 300 250 Kg': 250.0,
    'Ultrafloc 4002 240 Kg': 240.0,
    'Ultrafloc 4002 1150 Kg': 1150.0,
    'Ultrafloc 4010 250 Kg': 250.0,
    'Ultrafloc 4020 1000 Kg': 1000.0,
  };
  
  /// Obtener el factor de conversión para una referencia específica
  static double getConversionFactor(String reference) {
    return _conversionFactors[reference] ?? 1.0;
  }
  
  /// Convertir unidades a cantidad en kg o litros
  static double convertToQuantity(String reference, double units) {
    final factor = getConversionFactor(reference);
    return units * factor;
  }
  
  /// Calcular la cantidad total para un reporte
  static double calculateTotalQuantity(Report report) {
    // Para plantas tipo llenado
    if (report.plant.id == '9') {
      final referencia = report.getString('referencia');
      final unidades = report.getNumeric('unidades');
      return convertToQuantity(referencia, unidades);
    }
    
    // Para otras plantas con producción directa en kg o litros
    double total = 0.0;
    
    // Sumar todas las producciones
    report.data.forEach((key, value) {
      if (key.contains('produccion') && !key.contains('tipo')) {
        total += report.getNumeric(key);
      }
    });
    
    return total;
  }
  
  /// Calcular la eficiencia del proceso
  static double calculateEfficiency(Report report) {
    // Eficiencia básica (puede personalizarse según la planta)
    switch (report.plant.id) {
      case '1': // Sulfato de Aluminio Tipo A
        // Producción en unidades (reacción)
        final prod1 = report.getNumeric('produccion_stas_1ra_reaccion');
        final prod2 = report.getNumeric('produccion_stas_2da_reaccion');
        
        // Producción total en kg
        final prodLiquida = report.getNumeric('produccion_liquida');
        final prodTotal = (prod1 * 25.0) + (prod2 * 25.0) + prodLiquida;
        
        // Meta combinada: considerar todas las producciones
        const metaUnidades = 300.0; // 150 por reacción
        const metaLiquida = 10000.0; // kg
        const metaTotal = (metaUnidades * 25.0) + metaLiquida;
        
        return (prodTotal / metaTotal) * 100;
        
      case '2': // Sulfato de Aluminio Tipo B
        final prodEmpaque = report.getNumeric('produccion_stbs_empaque');
        final prodTanque = report.getNumeric('produccion_stbl_tanque');
        
        // Convertir unidades a kg
        final prodEmpaqueKg = prodEmpaque * 25.0;
        final prodTotal = prodEmpaqueKg + prodTanque;
        
        // Meta combinada
        const metaEmpaqueKg = 200 * 25.0; // 200 unidades * 25kg
        const metaTanque = 40000.0; // kg
        const metaTotal = metaEmpaqueKg + metaTanque;
        
        return (prodTotal / metaTotal) * 100;
        
      case '9': // Llenados
        final unidades = report.getNumeric('unidades');
        // Meta: 30 unidades por turno
        return (unidades / 30) * 100;
        
      default:
        // Cálculo genérico basado en datos disponibles
        double total = calculateTotalQuantity(report);
        double metaEstimada = _getTargetProduction(report.plant.id);
        return total > 0 ? (total / metaEstimada) * 100 : 0;
    }
  }
  
  /// Obtener producción objetivo para una planta
  static double _getTargetProduction(String plantId) {
    switch (plantId) {
      case '1': return 7500; // Sulfato A: ~300 unidades * 25kg
      case '2': return 40000; // Sulfato B
      case '3': return 5500; // Banalum: ~220 unidades * 25kg
      case '4': return 11000; // Bisulfito
      case '5': return 11000; // Silicatos
      case '6': return 9600; // Policloruro (5300 + 4300)
      case '7': return 5000; // Polímeros Catiónicos
      case '8': return 10200; // Polímeros Aniónicos (5200 + 5000)
      case '9': return 7500; // Llenados: 30 unidades * promedio 250kg
      default: return 10000; // Valor por defecto
    }
  }
  
  /// Generar métricas para un reporte
  static Map<String, dynamic> generateMetrics(Report report) {
    final totalQuantity = calculateTotalQuantity(report);
    final efficiency = calculateEfficiency(report);
    
    return {
      'cantidad_total': totalQuantity,
      'eficiencia': efficiency,
      'unidades_procesadas': _getProcessedUnits(report),
    };
  }
  
  /// Obtener cantidad de unidades procesadas
  static double _getProcessedUnits(Report report) {
    // Para plantas tipo llenado, usar directamente las unidades
    if (report.plant.id == '9') {
      return report.getNumeric('unidades');
    }
    
    // Para otras plantas, inferir de los datos disponibles
    double units = 0.0;
    
    report.data.forEach((key, value) {
      if ((key.contains('produccion') && key.contains('empaque')) || 
          key.contains('unidades')) {
        units += report.getNumeric(key);
      }
    });
    
    // Si no hay datos específicos de unidades, estimar a partir de cantidad
    if (units == 0.0) {
      // Estimar unidades a partir de producción total
      double totalQuantity = calculateTotalQuantity(report);
      double avgUnitWeight = _getAverageUnitWeight(report.plant.id);
      units = totalQuantity / avgUnitWeight;
    }
    
    return units;
  }
  
  /// Obtener peso promedio por unidad según tipo de planta
  static double _getAverageUnitWeight(String plantId) {
    switch (plantId) {
      case '1': case '2': case '3': return 25.0; // Bolsas de 25kg típicamente
      case '4': case '5': return 250.0; // Contenedores de 250kg típicamente
      case '6': case '7': case '8': return 250.0; // Contenedores de 250kg típicamente
      default: return 250.0; // Valor por defecto
    }
  }
}