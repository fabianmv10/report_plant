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
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      leader: json['leader'],
      shift: json['shift'],
      plant: plant,
      data: json['data'],
      notes: json['notes'],
    );
  }
}