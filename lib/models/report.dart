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
    required this.notes,
  });
}