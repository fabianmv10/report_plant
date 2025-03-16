import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/report.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reports.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Crear tabla de plantas
    await db.execute('''
    CREATE TABLE plants(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT
    )
    ''');

    // Crear tabla de reportes
    await db.execute('''
    CREATE TABLE reports(
      id TEXT PRIMARY KEY,
      timestamp INTEGER NOT NULL,
      operator TEXT NOT NULL,
      shift TEXT NOT NULL,
      plant_id TEXT NOT NULL,
      data TEXT NOT NULL,
      notes TEXT,
      FOREIGN KEY (plant_id) REFERENCES plants (id)
    )
    ''');
  }

  // Métodos para plantas
  Future<int> insertPlant(Plant plant) async {
    final db = await instance.database;
    return await db.insert('plants', {
      'id': plant.id,
      'name': plant.name,
    });
  }

  Future<List<Plant>> getAllPlants() async {
    final db = await instance.database;
    final result = await db.query('plants');
    
    return result.map((json) => Plant(
      id: json['id'] as String,
      name: json['name'] as String,
    )).toList();
  }

  // Métodos para reportes
  Future<int> insertReport(Report report) async {
    final db = await instance.database;
    
    // Asegurarse que la planta existe
    await insertPlant(report.plant);
    
    return await db.insert('reports', {
      'id': report.id,
      'timestamp': report.timestamp.millisecondsSinceEpoch,
      'operator': report.operator,
      'shift': report.shift,
      'plant_id': report.plant.id,
      'data': jsonEncode(report.data),
      'notes': report.notes,
    });
  }

  Future<List<Report>> getAllReports() async {
    final db = await instance.database;
    
    // Obtener reportes con JOIN a plantas
    final result = await db.rawQuery('''
    SELECT r.*, p.name as plant_name, p.description as plant_description
    FROM reports r
    JOIN plants p ON r.plant_id = p.id
    ORDER BY r.timestamp DESC
    ''');
    
    return result.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      return Report(
        id: json['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        operator: json['operator'] as String,
        shift: json['shift'] as String,
        plant: plant,
        data: jsonDecode(json['data'] as String),
        notes: json['notes'] as String?,
      );
    }).toList();
  }

  Future<List<Report>> getReportsByPlant(String plantId) async {
    final db = await instance.database;
    
    final result = await db.rawQuery('''
    SELECT r.*, p.name as plant_name, p.description as plant_description
    FROM reports r
    JOIN plants p ON r.plant_id = p.id
    WHERE r.plant_id = ?
    ORDER BY r.timestamp DESC
    ''', [plantId]);
    
    return result.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      return Report(
        id: json['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        operator: json['operator'] as String,
        shift: json['shift'] as String,
        plant: plant,
        data: jsonDecode(json['data'] as String),
        notes: json['notes'] as String?,
      );
    }).toList();
  }

  Future<int> updateReport(Report report) async {
    final db = await instance.database;
    
    return db.update(
      'reports',
      {
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'operator': report.operator,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
      },
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<int> deleteReport(String id) async {
    final db = await instance.database;
    
    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}