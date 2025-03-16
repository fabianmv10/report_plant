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
  final String operator;
  final String shift;
  final Plant plant;
  final Map<String, dynamic> data;
  final String? notes;

  Report({
    required this.id,
    required this.timestamp, 
    required this.operator, 
    required this.shift,
    required this.plant,
    required this.data,
    this.notes,
  });

  // Convertir reporte a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'operator': operator,
    'shift': shift,
    'plant_id': plant.id,
    'data': data,
    'notes': notes,
  };

  // Crear reporte desde JSON
  factory Report.fromJson(Map<String, dynamic> json, Plant plant) {
    return Report(
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      operator: json['operator'],
      shift: json['shift'],
      plant: plant,
      data: json['data'],
      notes: json['notes'],
    );
  }
}