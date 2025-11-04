class Plant {
  final String id;
  final String name;

  Plant({
    required this.id,
    required this.name,
  });
}

class Report {
  final String id;
  final DateTime timestamp;
  final String leader;
  final String shift;
  final Plant plant;
  final Map<String, dynamic> data;
  final String? notes;

  Report({
    required this.id,
    required this.timestamp, 
    required this.leader, 
    required this.shift,
    required this.plant,
    required this.data,
    this.notes,
  });

  // Método seguro para obtener números del mapa de datos
  double getNumeric(String key, [double defaultValue = 0.0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
  
  // Método seguro para obtener strings del mapa de datos
  String getString(String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    
    return value.toString();
  }

  // Convertir reporte a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'leader': leader,
    'shift': shift,
    'plant_id': plant.id,
    'data': data,
    'notes': notes,
  };

  // Crear reporte desde JSON
  factory Report.fromJson(Map<String, dynamic> json, Plant plant) {
    return Report(
      id: json['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      leader: json['leader'] as String,
      shift: json['shift'] as String,
      plant: plant,
      data: json['data'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
    );
  }
}