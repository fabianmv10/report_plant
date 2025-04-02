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

  // En database_helper.dart, modifica _initDB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // ignore: avoid_print
    print("Creando base de datos en: $path");

    try {
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          // ignore: avoid_print
          print("Creando tablas de la base de datos");
          _createDB(db, version);
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print("Error al crear la base de datos: $e");
      // Puede ser necesario eliminar el archivo de la base de datos si está corrupto
      // await deleteDatabase(path);
      rethrow;
    }
  }
  // ignore: avoid-unused-parameters
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
      leader TEXT NOT NULL,
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
    try {
      final db = await instance.database;
      
      // En lugar de intentar insertar la planta directamente, verifica primero si existe
      final List<Map<String, dynamic>> existingPlants = await db.query(
        'plants',
        where: 'id = ?',
        whereArgs: [report.plant.id],
      );
      
      // Si la planta no existe, insértala
      if (existingPlants.isEmpty) {
        await insertPlant(report.plant);
      }
      
      final reportMap = {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
      };
      
      // ignore: avoid_print
      print("Insertando reporte: $reportMap");
      return await db.insert('reports', reportMap);
    } catch (e) {
      // ignore: avoid_print
      print("Error insertando reporte: $e");
      return -1;
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      final db = await instance.database;
      
      // Obtener reportes con JOIN a plantas
      final result = await db.rawQuery('''
      SELECT r.*, p.name as plant_name
      FROM reports r
      JOIN plants p ON r.plant_id = p.id
      ORDER BY r.timestamp DESC
      ''');
      
      return _processReportResults(result);
    } catch (e) {
      // ignore: avoid_print
      print("Error obteniendo reportes: $e");
      return [];
    }
  }

  List<Report> _processReportResults(List<Map<String, dynamic>> results) {
    return results.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      final reportData = _parseReportData(json['data'] as String);
      
      return Report(
        id: json['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        leader: json['leader'] as String,
        shift: json['shift'] as String,
        plant: plant,
        data: reportData,
        notes: json['notes'] as String?,
      );
    }).toList();
  }

  Map<String, dynamic> _parseReportData(String dataJson) {
    try {
      // Intentar parsear el JSON
      final reportData = Map<String, dynamic>.from(jsonDecode(dataJson));
      
      // Convertir strings a tipos numéricos donde corresponda
      reportData.forEach((key, value) {
        if (value is String) {
          reportData[key] = _convertStringValueToNumeric(key, value);
        } else if (value == null) {
          reportData[key] = _getDefaultValueForField(key);
        }
      });
      
      return reportData;
    } catch (e) {
      // ignore: avoid_print
      print("Error deserializando datos de reporte: $e");
      return {};
    }
  }

  // ignore: avoid-unused-parameters
  dynamic _convertStringValueToNumeric(String key, String value) {
    try {
      if (value.contains('.')) {
        return double.parse(value);
      } else {
        return int.parse(value);
      }
    } catch (_) {
      // Si falla la conversión, mantener como string
      return value;
    }
  }

  dynamic _getDefaultValueForField(String key) {
    if (key.contains('cantidad') || 
        key.contains('produccion') || 
        key.contains('reaccion')) {
      return 0.0;
    }
    return '';
  }


  Future<List<Report>> getReportsByPlant(String plantId) async {
    final db = await instance.database;
    
    final result = await db.rawQuery('''
    SELECT r.*, p.name as plant_name, p.description as plant_description
    FROM reports r
    JOIN plants p ON r.plant_id = p.id
    WHERE r.plant_id = ?
    ORDER BY r.timestamp DESC
    ''', [plantId],);
    
    return result.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      return Report(
        id: json['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        leader: json['leader'] as String,
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
        'leader': report.leader,
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

  // Añade esto al DatabaseHelper para depurar
  Future<void> logDatabasePath() async {
    final dbPath = await getDatabasesPath();
    // ignore: avoid_print
    print("Database path: $dbPath");
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}