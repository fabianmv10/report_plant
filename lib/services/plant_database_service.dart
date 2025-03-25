// lib/services/plant_database_service.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/report.dart';

/// Servicio para gestionar bases de datos personalizadas por planta
class PlantDatabaseService {
  // Singleton
  static final PlantDatabaseService instance = PlantDatabaseService._init();
  PlantDatabaseService._init();
  
  // Mapa de bases de datos por planta
  final Map<String, Database> _plantDatabases = {};
  
  // Método para obtener una base de datos específica para una planta
  Future<Database> getDatabaseForPlant(String plantId) async {
    if (_plantDatabases.containsKey(plantId)) {
      return _plantDatabases[plantId]!;
    }
    
    // Crear y configurar la base de datos
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'plant_$plantId.db');
    
    // Abrir o crear la base de datos con esquema específico para esta planta
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createPlantSpecificTables(db, plantId);
      },
    );
    
    _plantDatabases[plantId] = db;
    return db;
  }
  
  /// Crear tablas específicas según el tipo de planta
  Future<void> _createPlantSpecificTables(Database db, String plantId) async {
    // Tabla común para todos los reportes
    await db.execute('''
      CREATE TABLE reports(
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        leader TEXT NOT NULL,
        shift TEXT NOT NULL,
        notes TEXT
      )
    ''');
    
    // Crear índice para búsquedas por fecha
    await db.execute('CREATE INDEX idx_reports_timestamp ON reports(timestamp)');
    
    // Tabla para métricas calculadas (común a todas las plantas)
    await db.execute('''
      CREATE TABLE metrics(
        report_id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        total_produccion REAL,
        eficiencia REAL,
        FOREIGN KEY (report_id) REFERENCES reports (id)
      )
    ''');
    
    // Tabla para tendencias (común a todas las plantas)
    await db.execute('''
      CREATE TABLE trends(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        metric_name TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        value REAL NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_trends_metric ON trends(metric_name, timestamp)');
    
    // Crear tablas específicas por planta
    switch (plantId) {
      case '1': // Sulfato de Aluminio Tipo A
        await db.execute('''
          CREATE TABLE sulfato_tipo_a(
            report_id TEXT PRIMARY KEY,
            referencia TEXT NOT NULL,
            produccion_primera_reaccion REAL NOT NULL,
            produccion_segunda_reaccion REAL NOT NULL,
            produccion_liquida REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '2': // Sulfato de Aluminio Tipo B
        await db.execute('''
          CREATE TABLE sulfato_tipo_b(
            report_id TEXT PRIMARY KEY,
            reaccion_de_stbs REAL NOT NULL,
            produccion_stbs_empaque REAL NOT NULL,
            reaccion_de_stbl REAL NOT NULL,
            decantador_de_stbl REAL NOT NULL,
            produccion_stbl_tanque REAL NOT NULL,
            tanque_stbl TEXT NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '3': // Banalum
        await db.execute('''
          CREATE TABLE banalum(
            report_id TEXT PRIMARY KEY,
            referencia_reaccion TEXT NOT NULL,
            tipo_produccion TEXT NOT NULL,
            equipo_reaccion TEXT NOT NULL,
            tipo_empaque TEXT NOT NULL,
            cristalizador_empaque TEXT NOT NULL,
            produccion_empaque REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '4': // Bisulfito de Sodio
        await db.execute('''
          CREATE TABLE bisulfito_sodio(
            report_id TEXT PRIMARY KEY,
            estado_produccion TEXT NOT NULL,
            producción_bisulfito REAL NOT NULL,
            ph_concentrador_1 REAL NOT NULL,
            densidad_concentrador_1 REAL NOT NULL,
            ph_concentrador_2 REAL NOT NULL,
            densidad_concentrador_2 REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '5': // Silicatos
        await db.execute('''
          CREATE TABLE silicatos(
            report_id TEXT PRIMARY KEY,
            referencia_reaccion TEXT NOT NULL,
            reaccion_de_silicato REAL NOT NULL,
            produccion_de_silicato REAL NOT NULL,
            baume REAL NOT NULL,
            presion REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '6': // Policloruro de Aluminio
        await db.execute('''
          CREATE TABLE policloruro(
            report_id TEXT PRIMARY KEY,
            reaccion_de_cloal TEXT NOT NULL,
            produccion_cloal REAL NOT NULL,
            densidad_cloal REAL NOT NULL,
            reaccion_de_policloruro TEXT NOT NULL,
            produccion_policloruro REAL NOT NULL,
            densidad_policloruro REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '7': // Polímeros Catiónicos
        await db.execute('''
          CREATE TABLE polimeros_cationicos(
            report_id TEXT PRIMARY KEY,
            referencia_reaccion TEXT NOT NULL,
            produccion_polimero REAL NOT NULL,
            densidad_polimero REAL NOT NULL,
            ph_polimero REAL NOT NULL,
            solidos_polimero REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '8': // Polímeros Aniónicos
        await db.execute('''
          CREATE TABLE polimeros_anionicos(
            report_id TEXT PRIMARY KEY,
            referencia_reaccion TEXT NOT NULL,
            produccion_polimero REAL NOT NULL,
            densidad_polimero REAL NOT NULL,
            ph_polimero REAL NOT NULL,
            solidos_polimero REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      case '9': // Llenados
        await db.execute('''
          CREATE TABLE llenados(
            report_id TEXT PRIMARY KEY,
            referencia TEXT NOT NULL,
            unidades REAL NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
        break;
        
      default:
        // Tabla genérica para otras plantas
        await db.execute('''
          CREATE TABLE parameters(
            report_id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            FOREIGN KEY (report_id) REFERENCES reports (id)
          )
        ''');
    }
  }
  
  /// Obtener el nombre de la tabla específica para los datos de una planta
  String _getDataTableName(String plantId) {
    switch (plantId) {
      case '1': return 'sulfato_tipo_a';
      case '2': return 'sulfato_tipo_b';
      case '3': return 'banalum';
      case '4': return 'bisulfito_sodio';
      case '5': return 'silicatos';
      case '6': return 'policloruro';
      case '7': return 'polimeros_cationicos';
      case '8': return 'polimeros_anionicos';
      case '9': return 'llenados';
      default: return 'parameters';
    }
  }
  
  /// Insertar un reporte en la base de datos específica de la planta
  Future<bool> insertReport(Report report) async {
    final db = await getDatabaseForPlant(report.plant.id);
    
    // Iniciar transacción para garantizar consistencia
    return await db.transaction((txn) async {
      try {
        // 1. Insertar datos comunes en la tabla de reportes
        await txn.insert('reports', {
          'id': report.id,
          'timestamp': report.timestamp.millisecondsSinceEpoch,
          'leader': report.leader,
          'shift': report.shift,
          'notes': report.notes,
        });
        
        // 2. Insertar datos específicos en la tabla correspondiente a la planta
        final dataTableName = _getDataTableName(report.plant.id);
        
        if (dataTableName == 'parameters') {
          // Para plantas sin esquema específico, usar almacenamiento JSON
          await txn.insert(dataTableName, {
            'report_id': report.id,
            'data': jsonEncode(report.data),
          });
        } else {
          // Para plantas con esquema específico, insertar en columnas dedicadas
          final Map<String, dynamic> plantSpecificData = {
            'report_id': report.id,
          };
          
          // Mapear datos del reporte a las columnas específicas
          report.data.forEach((key, value) {
            plantSpecificData[key] = value;
          });
          
          await txn.insert(dataTableName, plantSpecificData);
        }
        
        return true;
      } catch (e) {
        print("Error insertando reporte en base de datos de planta: $e");
        return false;
      }
    });
  }
  
  /// Guardar métricas calculadas para un reporte
  Future<bool> saveMetrics(String plantId, String reportId, Map<String, dynamic> metrics) async {
    final db = await getDatabaseForPlant(plantId);
    
    try {
      // Preparar datos con columnas específicas
      final metricsMap = {
        'report_id': reportId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Agregar métricas específicas
      if (metrics.containsKey('total_produccion')) {
        metricsMap['total_produccion'] = metrics['total_produccion'];
      }
      
      if (metrics.containsKey('eficiencia')) {
        metricsMap['eficiencia'] = metrics['eficiencia'];
      }
      
      // Verificar si ya existen métricas para este reporte
      final existing = await db.query(
        'metrics',
        where: 'report_id = ?',
        whereArgs: [reportId],
      );
      
      if (existing.isNotEmpty) {
        // Actualizar métricas existentes
        await db.update(
          'metrics',
          metricsMap,
          where: 'report_id = ?',
          whereArgs: [reportId],
        );
      } else {
        // Insertar nuevas métricas
        await db.insert('metrics', metricsMap);
      }
      
      return true;
    } catch (e) {
      print("Error guardando métricas: $e");
      return false;
    }
  }
  
  /// Guardar datos para tendencias históricas
  Future<void> saveTrendData(String plantId, String metricName, double value) async {
    final db = await getDatabaseForPlant(plantId);
    
    try {
      // Insertar datos de tendencia
      await db.insert('trends', {
        'metric_name': metricName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'value': value,
      });
    } catch (e) {
      print("Error guardando datos de tendencia: $e");
    }
  }
  
  /// Obtener un reporte completo (con datos específicos de la planta)
  Future<Report?> getReport(String plantId, String reportId, Plant plant) async {
    final db = await getDatabaseForPlant(plantId);
    
    try {
      // Obtener datos básicos del reporte
      final reportResult = await db.query(
        'reports',
        where: 'id = ?',
        whereArgs: [reportId],
      );
      
      if (reportResult.isEmpty) {
        return null;
      }
      
      final reportData = reportResult.first;
      
      // Obtener datos específicos de la planta
      final dataTableName = _getDataTableName(plantId);
      final plantDataResult = await db.query(
        dataTableName,
        where: 'report_id = ?',
        whereArgs: [reportId],
      );
      
      // Convertir datos específicos al formato esperado
      Map<String, dynamic> specificData = {};
      
      if (plantDataResult.isNotEmpty) {
        if (dataTableName == 'parameters') {
          // Para tablas genéricas, deserializar JSON
          specificData = jsonDecode(plantDataResult.first['data'] as String);
        } else {
          // Para tablas específicas, extraer campos excepto report_id
          final rawData = plantDataResult.first;
          rawData.forEach((key, value) {
            if (key != 'report_id') {
              specificData[key] = value;
            }
          });
        }
      }
      
      // Construir el reporte completo
      return Report(
        id: reportId,
        timestamp: DateTime.fromMillisecondsSinceEpoch(reportData['timestamp'] as int),
        leader: reportData['leader'] as String,
        shift: reportData['shift'] as String,
        plant: plant,
        data: specificData,
        notes: reportData['notes'] as String?,
      );
    } catch (e) {
      print("Error obteniendo reporte: $e");
      return null;
    }
  }
  
  /// Obtener todos los reportes para una planta específica
  Future<List<Report>> getReportsForPlant(Plant plant) async {
    final db = await getDatabaseForPlant(plant.id);
    final dataTableName = _getDataTableName(plant.id);
    
    try {
      // Obtener todos los reportes con sus datos específicos en una sola consulta
      final query = '''
        SELECT r.*, d.*
        FROM reports r
        LEFT JOIN $dataTableName d ON r.id = d.report_id
        ORDER BY r.timestamp DESC
      ''';
      
      final results = await db.rawQuery(query);
      
      return results.map((row) {
        // Extraer datos específicos según el esquema
        final Map<String, dynamic> specificData = {};
        
        if (dataTableName == 'parameters' && row.containsKey('data')) {
          // Para tablas genéricas, deserializar JSON
          specificData.addAll(jsonDecode(row['data'] as String));
        } else {
          // Para tablas específicas, extraer todos los campos específicos
          row.forEach((key, value) {
            if (key != 'id' && 
                key != 'timestamp' && 
                key != 'leader' && 
                key != 'shift' && 
                key != 'notes' && 
                key != 'report_id') {
              specificData[key] = value;
            }
          });
        }
        
        // Construir y retornar el reporte
        return Report(
          id: row['id'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          leader: row['leader'] as String,
          shift: row['shift'] as String,
          plant: plant,
          data: specificData,
          notes: row['notes'] as String?,
        );
      }).toList();
    } catch (e) {
      print("Error obteniendo reportes para planta ${plant.id}: $e");
      return [];
    }
  }
  
  /// Obtener reportes por fecha para una planta específica
  Future<List<Report>> getReportsByDate(Plant plant, DateTime date) async {
    final db = await getDatabaseForPlant(plant.id);
    
    // Calcular rango de fechas (inicio y fin del día)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final startTimestamp = startOfDay.millisecondsSinceEpoch;
    final endTimestamp = endOfDay.millisecondsSinceEpoch;
    
    try {
      final dataTableName = _getDataTableName(plant.id);
      
      // Consulta para obtener reportes y sus datos específicos
      final query = '''
        SELECT r.*, d.*
        FROM reports r
        LEFT JOIN $dataTableName d ON r.id = d.report_id
        WHERE r.timestamp BETWEEN ? AND ?
        ORDER BY r.timestamp ASC
      ''';
      
      final results = await db.rawQuery(query, [startTimestamp, endTimestamp]);
      
      return results.map((row) {
        // Extraer datos específicos según el esquema
        final Map<String, dynamic> specificData = {};
        
        if (dataTableName == 'parameters' && row.containsKey('data')) {
          // Para tablas genéricas, deserializar JSON
          specificData.addAll(jsonDecode(row['data'] as String));
        } else {
          // Para tablas específicas, extraer todos los campos específicos
          row.forEach((key, value) {
            if (key != 'id' && 
                key != 'timestamp' && 
                key != 'leader' && 
                key != 'shift' && 
                key != 'notes' && 
                key != 'report_id') {
              specificData[key] = value;
            }
          });
        }
        
        // Construir y retornar el reporte
        return Report(
          id: row['id'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          leader: row['leader'] as String,
          shift: row['shift'] as String,
          plant: plant,
          data: specificData,
          notes: row['notes'] as String?,
        );
      }).toList();
    } catch (e) {
      print("Error obteniendo reportes por fecha: $e");
      return [];
    }
  }
  
  /// Obtener reportes por rango de fechas
  Future<List<Report>> getReportsByDateRange(Plant plant, DateTime startDate, DateTime endDate) async {
    final db = await getDatabaseForPlant(plant.id);
    
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.add(const Duration(days: 1)).millisecondsSinceEpoch;
    
    try {
      final dataTableName = _getDataTableName(plant.id);
      
      // Consulta para obtener reportes y sus datos específicos
      final query = '''
        SELECT r.*, d.*
        FROM reports r
        LEFT JOIN $dataTableName d ON r.id = d.report_id
        WHERE r.timestamp BETWEEN ? AND ?
        ORDER BY r.timestamp ASC
      ''';
      
      final results = await db.rawQuery(query, [startTimestamp, endTimestamp]);
      
      return results.map((row) {
        // Extraer datos específicos según el esquema
        final Map<String, dynamic> specificData = {};
        
        if (dataTableName == 'parameters' && row.containsKey('data')) {
          // Para tablas genéricas, deserializar JSON
          specificData.addAll(jsonDecode(row['data'] as String));
        } else {
          // Para tablas específicas, extraer todos los campos específicos
          row.forEach((key, value) {
            if (key != 'id' && 
                key != 'timestamp' && 
                key != 'leader' && 
                key != 'shift' && 
                key != 'notes' && 
                key != 'report_id') {
              specificData[key] = value;
            }
          });
        }
        
        // Construir y retornar el reporte
        return Report(
          id: row['id'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          leader: row['leader'] as String,
          shift: row['shift'] as String,
          plant: plant,
          data: specificData,
          notes: row['notes'] as String?,
        );
      }).toList();
    } catch (e) {
      print("Error obteniendo reportes por rango de fechas: $e");
      return [];
    }
  }
  
  /// Obtener métricas calculadas para un reporte específico
  Future<Map<String, dynamic>> getMetricsForReport(String plantId, String reportId) async {
    final db = await getDatabaseForPlant(plantId);
    
    try {
      final result = await db.query(
        'metrics',
        where: 'report_id = ?',
        whereArgs: [reportId],
      );
      
      if (result.isEmpty) {
        return {};
      }
      
      final metrics = result.first;
      final metricsMap = <String, dynamic>{};
      
      // Extraer cada métrica específica
      if (metrics.containsKey('total_produccion')) {
        metricsMap['total_produccion'] = metrics['total_produccion'];
      }
      
      if (metrics.containsKey('eficiencia')) {
        metricsMap['eficiencia'] = metrics['eficiencia'];
      }
      
      return metricsMap;
    } catch (e) {
      print("Error obteniendo métricas para reporte: $e");
      return {};
    }
  }
  
  /// Obtener datos históricos para una métrica específica
  Future<List<Map<String, dynamic>>> getTrendData(
    String plantId, 
    String metricName, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final db = await getDatabaseForPlant(plantId);
    
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;
    
    try {
      final result = await db.query(
        'trends',
        where: 'metric_name = ? AND timestamp BETWEEN ? AND ?',
        whereArgs: [metricName, startTimestamp, endTimestamp],
        orderBy: 'timestamp ASC',
      );
      
      return result.map((row) {
        return {
          'timestamp': DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          'value': row['value'] as double,
        };
      }).toList();
    } catch (e) {
      print("Error obteniendo datos de tendencia: $e");
      return [];
    }
  }
  
  /// Actualizar un reporte existente
  Future<bool> updateReport(Report report) async {
    final db = await getDatabaseForPlant(report.plant.id);
    
    return await db.transaction((txn) async {
      try {
        // 1. Actualizar datos comunes
        await txn.update(
          'reports',
          {
            'leader': report.leader,
            'shift': report.shift,
            'notes': report.notes,
          },
          where: 'id = ?',
          whereArgs: [report.id],
        );
        
        // 2. Actualizar datos específicos
        final dataTableName = _getDataTableName(report.plant.id);
        
        if (dataTableName == 'parameters') {
          // Para plantas sin esquema específico
          await txn.update(
            dataTableName,
            {'data': jsonEncode(report.data)},
            where: 'report_id = ?',
            whereArgs: [report.id],
          );
        } else {
          // Para plantas con esquema específico
          final Map<String, dynamic> plantSpecificData = {};
          
          // Mapear datos del reporte a las columnas específicas
          report.data.forEach((key, value) {
            plantSpecificData[key] = value;
          });
          
          await txn.update(
            dataTableName,
            plantSpecificData,
            where: 'report_id = ?',
            whereArgs: [report.id],
          );
        }
        
        return true;
      } catch (e) {
        print("Error actualizando reporte: $e");
        return false;
      }
    });
  }
  
  /// Eliminar un reporte
  Future<bool> deleteReport(String plantId, String reportId) async {
    final db = await getDatabaseForPlant(plantId);
    
    return await db.transaction((txn) async {
      try {
        // Eliminar métricas asociadas
        await txn.delete(
          'metrics',
          where: 'report_id = ?',
          whereArgs: [reportId],
        );
        
        // Eliminar datos específicos
        final dataTableName = _getDataTableName(plantId);
        await txn.delete(
          dataTableName,
          where: 'report_id = ?',
          whereArgs: [reportId],
        );
        
        // Eliminar reporte base
        await txn.delete(
          'reports',
          where: 'id = ?',
          whereArgs: [reportId],
        );
        
        return true;
      } catch (e) {
        print("Error eliminando reporte: $e");
        return false;
      }
    });
  }
  
  /// Cerrar todas las bases de datos
  Future<void> closeAll() async {
    for (final db in _plantDatabases.values) {
      await db.close();
    }
    _plantDatabases.clear();
  }
  
  /// Obtener el esquema para una planta específica
  Future<List<Map<String, dynamic>>> getPlantSchema(String plantId) async {
    final db = await getDatabaseForPlant(plantId);
    final dataTableName = _getDataTableName(plantId);
    
    try {
      // Obtener estructura de la tabla específica
      final pragmaResult = await db.rawQuery('PRAGMA table_info($dataTableName)');
      
      // Filtrar solo columnas relevantes (excluir report_id)
      return pragmaResult
          .where((column) => column['name'] != 'report_id')
          .map((column) => {
                'name': column['name'],
                'type': _sqliteTypeToFieldType(column['type'] as String),
              })
          .toList();
    } catch (e) {
      print("Error obteniendo esquema: $e");
      return [];
    }
  }
  
  // Convertir tipo SQLite a tipo de campo
  String _sqliteTypeToFieldType(String sqlType) {
    sqlType = sqlType.toUpperCase();
    if (sqlType.contains('INT')) {
      return 'numeric';
    } else if (sqlType.contains('REAL')) {
      return 'numeric';
    } else if (sqlType.contains('TEXT')) {
      return 'text';
    } else {
      return 'text';
    }
  }
  
  /// Método auxiliar para importar del sistema antiguo
  Future<void> importLegacyData(Report legacyReport) async {
    // Convertir formato antiguo al nuevo
    try {
      await insertReport(legacyReport);
    } catch (e) {
      print("Error importando datos antiguos: $e");
    }
  }
}