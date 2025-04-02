import 'report.dart';
import '../services/unit_converter_service.dart';

/// Extensión para añadir funcionalidades de métricas al modelo Report
extension ReportMetrics on Report {
  /// Calcular la cantidad total en kg o litros
  double calculateTotalQuantity() {
    return UnitConverterService.calculateTotalQuantity(this);
  }
  
  /// Calcular la eficiencia del proceso
  double calculateEfficiency() {
    return UnitConverterService.calculateEfficiency(this);
  }
  
  /// Generar todas las métricas para este reporte
  Map<String, dynamic> generateMetrics() {
    return UnitConverterService.generateMetrics(this);
  }
  
  /// Obtener la tendencia de crecimiento comparado con otro reporte
  double getTrendPercentage(Report? previousReport) {
    if (previousReport == null) return 0.0;
    
    double currentQuantity = calculateTotalQuantity();
    double previousQuantity = previousReport.calculateTotalQuantity();
    
    if (previousQuantity == 0) return 0.0;
    
    return ((currentQuantity - previousQuantity) / previousQuantity) * 100;
  }
  
  /// Verificar si se cumplió la meta de producción
  bool metProductionTarget() {
    return calculateEfficiency() >= 100.0;
  }
  
  /// Obtener el color de estado basado en la eficiencia
  int getStatusColor() {
    double efficiency = calculateEfficiency();
    
    if (efficiency >= 90) return 0xFF388E3C; // Verde
    if (efficiency >= 75) return 0xFFF57C00; // Naranja
    return 0xFFD32F2F; // Rojo
  }
  
  /// Convertir unidades a cantidad para campos específicos
  double convertUnitToQuantity(String fieldName) {
    if (fieldName == 'unidades' && data.containsKey('referencia')) {
      String referencia = data['referencia'].toString();
      double unidades = getNumeric(fieldName);
      return UnitConverterService.convertToQuantity(referencia, unidades);
    }
    
    return getNumeric(fieldName);
  }
}