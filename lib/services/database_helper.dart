// lib/services/database_helper.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/report.dart';
import 'api_client.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final ApiClient _apiClient = ApiClient.instance;

  DatabaseHelper._init();

  // Inicializar base de datos local (para caché y modo offline)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reports_cache.db');
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

  //ignore: avoid-unused-parameters
  Future _createDB(Database db, int version) async {
    // Crear tabla de plantas
    await db.execute('''
    CREATE TABLE plants(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      last_synced INTEGER
    )
    ''');

    // Crear tabla de reportes (caché local)
    await db.execute('''
    CREATE TABLE reports(
      id TEXT PRIMARY KEY,
      timestamp INTEGER NOT NULL,
      leader TEXT NOT NULL,
      shift TEXT NOT NULL,
      plant_id TEXT NOT NULL,
      data TEXT NOT NULL,
      notes TEXT,
      synced INTEGER DEFAULT 0,
      FOREIGN KEY (plant_id) REFERENCES plants (id)
    )
    ''');
  }

  // MÉTODOS PARA PLANTAS

  Future<int> insertPlant(Plant plant) async {
    try {
      // Intentar insertar en API REST
      final success = await _apiClient.insertPlant(plant);
      
      // Guardar localmente también (para caché)
      final db = await instance.database;
      final plantMap = {
        'id': plant.id,
        'name': plant.name,
        'last_synced': DateTime.now().millisecondsSinceEpoch,
      };
      
      await db.insert('plants', plantMap, 
        conflictAlgorithm: ConflictAlgorithm.replace,);
      
      return success ? 1 : 0;
    } catch (e) {
      print("Error al insertar planta remotamente: $e");
      
      // Guardar solo localmente si hay error
      final db = await instance.database;
      final plantMap = {
        'id': plant.id,
        'name': plant.name,
        'last_synced': 0, // No sincronizado
      };
      
      return await db.insert('plants', plantMap, 
        conflictAlgorithm: ConflictAlgorithm.replace,);
    }
  }

  Future<List<Plant>> getAllPlants() async {
    try {
      // Intentar obtener de la API REST
      final remotePlants = await _apiClient.getAllPlants();
      
      // Actualizar caché local
      if (remotePlants.isNotEmpty) {
        final db = await instance.database;
        for (var plant in remotePlants) {
          await db.insert(
            'plants', 
            {
              'id': plant.id,
              'name': plant.name,
              'last_synced': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      
      return remotePlants;
    } catch (e) {
      print('Error al obtener plantas remotas: $e');
      
      // Si hay error de conexión, obtener desde caché local
      final db = await instance.database;
      final result = await db.query('plants');
      
      // Si no hay plantas locales, usar las predeterminadas
      if (result.isEmpty) {
        final defaultPlants = [
          Plant(id: '1', name: 'Sulfato de Aluminio Tipo A'),
          Plant(id: '2', name: 'Sulfato de Aluminio Tipo B'),
          Plant(id: '3', name: 'Banalum'),
          Plant(id: '4', name: 'Bisulfito de Sodio'),
          Plant(id: '5', name: 'Silicatos'),
          Plant(id: '6', name: 'Policloruro de Aluminio'),
          Plant(id: '7', name: 'Polímeros Catiónicos'),
          Plant(id: '8', name: 'Polímeros Aniónicos'),
          Plant(id: '9', name: 'Llenados'),
        ];
        
        // Guardar plantas predeterminadas en la base de datos local
        for (var plant in defaultPlants) {
          await insertPlant(plant);
        }
        
        return defaultPlants;
      }
      
      return result.map((json) => Plant(
        id: json['id'] as String,
        name: json['name'] as String,
      )).toList();
    }
  }

  // MÉTODOS PARA REPORTES

  Future<int> insertReport(Report report) async {
    try {
      // Intentar insertar en API REST
      final success = await _apiClient.insertReport(report);
      
      if (success) {
        // Si se guardó exitosamente, también guardar localmente
        final db = await instance.database;
        final reportMap = {
          'id': report.id,
          'timestamp': report.timestamp.millisecondsSinceEpoch,
          'leader': report.leader,
          'shift': report.shift,
          'plant_id': report.plant.id,
          'data': jsonEncode(report.data),
          'notes': report.notes,
          'synced': 1, // Marcado como sincronizado
        };
        
        await db.insert('reports', reportMap, 
          conflictAlgorithm: ConflictAlgorithm.replace,);
          
        return 1; // Éxito
      } else {
        print("Error al guardar el reporte en el servidor");
        return _saveReportLocally(report);
      }
    } catch (e) {
      print("Error al guardar reporte remotamente: $e");
      return _saveReportLocally(report);
    }
  }

  // Método auxiliar para guardar reporte localmente
  Future<int> _saveReportLocally(Report report) async {
    try {
      final db = await instance.database;
      final reportMap = {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
        'synced': 0, // No sincronizado
      };
      
      return await db.insert('reports', reportMap, 
        conflictAlgorithm: ConflictAlgorithm.replace,);
    } catch (e) {
      print("Error al guardar reporte localmente: $e");
      return -1;
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      // Intentar obtener de la API REST
      final remoteReports = await _apiClient.getAllReports();
      
      // Actualizar caché local
      if (remoteReports.isNotEmpty) {
        _updateLocalCache(remoteReports);
      }
      
      return remoteReports;
    } catch (e) {
      print('Error al obtener reportes remotos: $e');
      // Si hay error de conexión, obtener desde caché local
      return _getLocalReports();
    }
  }

  Future<void> _updateLocalCache(List<Report> reports) async {
    final db = await instance.database;
    
    // Primero insertar/actualizar las plantas
    for (var report in reports) {
      await db.insert(
        'plants',
        {
          'id': report.plant.id,
          'name': report.plant.name,
          'last_synced': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    // Luego los reportes
    for (var report in reports) {
      await db.insert(
        'reports',
        {
          'id': report.id,
          'timestamp': report.timestamp.millisecondsSinceEpoch,
          'leader': report.leader,
          'shift': report.shift,
          'plant_id': report.plant.id,
          'data': jsonEncode(report.data),
          'notes': report.notes,
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Report>> _getLocalReports() async {
    final db = await instance.database;
    
    // Obtener reportes con JOIN a plantas
    final results = await db.rawQuery('''
    SELECT r.*, p.name as plant_name
    FROM reports r
    JOIN plants p ON r.plant_id = p.id
    ORDER BY r.timestamp DESC
    ''');
    
    return results.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      // Decodificar los datos JSON
      Map<String, dynamic> reportData;
      try {
        reportData = jsonDecode(json['data'] as String) as Map<String, dynamic>;
      } catch (e) {
        reportData = {};
      }

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

  Future<List<Report>> getReportsByPlant(String plantId) async {
    try {
      // Intentar obtener todos los reportes y filtrarlos
      final allReports = await getAllReports();
      return allReports.where((report) => report.plant.id == plantId).toList();
    } catch (e) {
      print('Error al obtener reportes por planta: $e');

      // Si hay error, obtener desde caché local
      final db = await instance.database;

      final results = await db.rawQuery('''
      SELECT r.*, p.name as plant_name
      FROM reports r
      JOIN plants p ON r.plant_id = p.id
      WHERE r.plant_id = ?
      ORDER BY r.timestamp DESC
      ''', [plantId],);

      return _processReportResults(results);
    }
  }

  List<Report> _processReportResults(List<Map<String, dynamic>> results) {
    return results.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );

      // Decodificar los datos JSON
      Map<String, dynamic> reportData;
      try {
        reportData = jsonDecode(json['data'] as String) as Map<String, dynamic>;
      } catch (e) {
        reportData = {};
      }
      
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

  // Sincronización de datos pendientes
  Future<bool> syncPendingReports() async {
    try {
      final db = await instance.database;
      
      // Obtener reportes no sincronizados
      final results = await db.query(
        'reports',
        where: 'synced = ?',
        whereArgs: [0],
      );
      
      if (results.isEmpty) return true;
      
      print("Intentando sincronizar ${results.length} reportes pendientes");
      
      // Sincronizar cada reporte
      int successCount = 0;
      
      for (var result in results) {
        // Obtener datos de la planta
        final plantId = result['plant_id'] as String;
        final plantResults = await db.query(
          'plants',
          where: 'id = ?',
          whereArgs: [plantId],
        );
        
        if (plantResults.isEmpty) continue;
        
        final plant = Plant(
          id: plantId,
          name: plantResults.first['name'] as String,
        );
        
        // Decodificar los datos JSON
        Map<String, dynamic> reportData;
        try {
          reportData = jsonDecode(result['data'] as String) as Map<String, dynamic>;
        } catch (e) {
          reportData = {};
        }
        
        // Crear objeto reporte
        final report = Report(
          id: result['id'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(result['timestamp'] as int),
          leader: result['leader'] as String,
          shift: result['shift'] as String,
          plant: plant,
          data: reportData,
          notes: result['notes'] as String?,
        );
        
        // Enviar a la API
        try {
          final success = await _apiClient.insertReport(report);
          
          // Actualizar estado de sincronización
          if (success) {
            await db.update(
              'reports',
              {'synced': 1},
              where: 'id = ?',
              whereArgs: [report.id],
            );
            successCount++;
            print("Reporte ${report.id} sincronizado exitosamente");
          }
        } catch (e) {
          print("Error al sincronizar reporte ${report.id}: $e");
          // Continuar con el siguiente reporte
        }
      }
      
      print("Sincronización completada. $successCount de ${results.length} reportes sincronizados exitosamente");
      return true;
    } catch (e) {
      print("Error durante la sincronización: $e");
      return false;
    }
  }

  // Exportación
  Future<String?> exportReportsToCSV() async {
    try {
      // Obtener todos los reportes (locales y remotos)
      List<Report> reports = [];
      
      try {
        reports = await getAllReports();
      } catch (e) {
        reports = await _getLocalReports();
      }
      
      if (reports.isEmpty) {
        return "No hay reportes para exportar";
      }
      
      // Construir el CSV
      StringBuffer csv = StringBuffer();
      
      // Encabezados
      csv.writeln('ID,Fecha,Líder,Turno,Planta,Notas');
      
      // Datos
      for (var report in reports) {
        final fecha = "${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year}";
        final notas = report.notes?.replaceAll('"', '""') ?? '';
        
        csv.writeln(
          '${report.id},"$fecha",${report.leader},${report.shift},${report.plant.name},"$notas"',
        );
      }
      
      return csv.toString();
    } catch (e) {
      print('Error exportando a CSV: $e');
      return null;
    }
  }

  Future<String?> exportReportsToJSON() async {
    try {
      // Obtener todos los reportes
      List<Report> reports = [];
      
      try {
        reports = await getAllReports();
      } catch (e) {
        reports = await _getLocalReports();
      }
      
      if (reports.isEmpty) {
        return null;
      }
      
      // Convertir a JSON
      List<Map<String, dynamic>> reportsList = reports.map((report) => {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'plant_name': report.plant.name,
        'data': report.data,
        'notes': report.notes,
      }).toList();
      
      return jsonEncode(reportsList);
    } catch (e) {
      print('Error exportando a JSON: $e');
      return null;
    }
  }
  
  Future close() async {
    final db = await instance.database;
    db.close();
  }
  
  Future<Map<String, dynamic>> syncAllData() async {
    try {
      // Contar reportes pendientes antes
      final db = await instance.database;
      final pendingBefore = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM reports WHERE synced = 0',
      )) ?? 0;
      
      // Sincronizar reportes pendientes
      final success = await syncPendingReports();
      
      // Contar reportes pendientes después
      final pendingAfter = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM reports WHERE synced = 0',
      )) ?? 0;
      
      // Actualizar plantas desde el servidor
      List<Plant> remotePlants = [];
      bool plantsSuccess = false;
      
      try {
        remotePlants = await _apiClient.getAllPlants();
        plantsSuccess = remotePlants.isNotEmpty;
      } catch (e) {
        plantsSuccess = false;
      }
      
      return {
        'success': success,
        'pendingBefore': pendingBefore,
        'pendingAfter': pendingAfter,
        'syncedCount': pendingBefore - pendingAfter,
        'plantsSuccess': plantsSuccess,
        'plantsCount': remotePlants.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}