// lib/services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import '../models/report.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  MySqlConnection? _connection;
  // ignore: unused_field
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 3;

  // Configuración de conexión a MySQL
  final ConnectionSettings settings = ConnectionSettings(
    host: '192.168.97.192',  // Cambia a la IP de tu computador si conectas desde otro dispositivo
    port: 3306,         // Puerto por defecto de MySQL
    user: 'admin',  // Usuario que creaste para la aplicación
    password: 'pqp2021@',  // Contraseña del usuario
    db: 'reportes_turno',  // Nombre de la base de datos
    timeout: const Duration(seconds: 30),
    useCompression: false,     // Deshabilita la compresión para simplificar
    useSSL: false,             // Deshabilita SSL para pruebas iniciales
  );
  
  ApiService._init();
  
  Future<MySqlConnection> get connection async {
    if (_connection != null && _isConnected) {
      try {
        // Verifica que la conexión sigue activa con una consulta simple
        await _connection!.query('SELECT 1');
        return _connection!;
      } catch (e) {
        print('La conexión existente falló: $e');
        _isConnected = false;
        _connection = null;
      }
    }
    
    return _createNewConnection();
  }
  
  Future<MySqlConnection> _createNewConnection() async {
    _reconnectAttempts = 0;
    while (_reconnectAttempts < _maxReconnectAttempts) {
      try {
        print('Intentando conectar a MySQL (intento ${_reconnectAttempts + 1})');
        final conn = await MySqlConnection.connect(settings);
        _connection = conn;
        _isConnected = true;
        _reconnectAttempts = 0;
        print('Conexión exitosa a MySQL');
        return conn;
      } catch (e) {
        _reconnectAttempts++;
        print('Error al conectar (intento $_reconnectAttempts): $e');
        if (_reconnectAttempts >= _maxReconnectAttempts) {
          _isConnected = false;
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * _reconnectAttempts)); // Backoff exponencial
      }
    }
    
    throw Exception('No se pudo conectar después de $_maxReconnectAttempts intentos');
  }
  
  // Cerrar conexión
  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      _isConnected = false;
    }
  }

  // PLANTAS
  
  // Obtener todas las plantas
  Future<List<Plant>> getAllPlants() async {
    final conn = await connection;
    
    try {
      final results = await conn.query('SELECT * FROM plants ORDER BY id');
      
      return results.map((row) => Plant(
        id: row['id'].toString(),
        name: row['name'].toString(),
      )).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo plantas: $e');
      }
      return [];
    }
  }
  
  // Insertar nueva planta
  Future<bool> insertPlant(Plant plant) async {
    final conn = await connection;
    
    try {
      final result = await conn.query(
        'INSERT INTO plants (id, name) VALUES (?, ?)',
        [plant.id, plant.name],
      );
      
      return result.affectedRows! > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error insertando planta: $e');
      }
      return false;
    }
  }
  
  // REPORTES
  
  // Insertar nuevo reporte con transacción
  Future<bool> insertReport(Report report) async {
    final conn = await connection;
    
    try {
      // Iniciar transacción
      await conn.query('START TRANSACTION');
      
      try {
        // 1. Verificar si la planta existe
        final plantExists = await conn.query(
          'SELECT COUNT(*) as count FROM plants WHERE id = ?',
          [report.plant.id],
        );
        
        // Si la planta no existe, insertarla
        if (plantExists.first['count'] == 0) {
          await insertPlant(report.plant);
        }
        
        // 2. Insertar datos comunes del reporte
        final result = await conn.query(
          'INSERT INTO reports (id, timestamp, leader, shift, plant_id, notes) VALUES (?, ?, ?, ?, ?, ?)',
          [
            report.id,
            report.timestamp.millisecondsSinceEpoch,
            report.leader,
            report.shift,
            report.plant.id,
            report.notes,
          ],
        );
        
        if (result.affectedRows! <= 0) {
          throw Exception('No se pudo insertar el reporte');
        }
        
        // 3. Insertar datos específicos de la planta
        await _insertPlantSpecificData(conn, report);
        
        // Confirmar transacción
        await conn.query('COMMIT');
        return true;
      } catch (e) {
        // Revertir transacción en caso de error
        await conn.query('ROLLBACK');
        if (kDebugMode) {
          print('Error en transacción: $e');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error insertando reporte: $e');
      }
      return false;
    }
  }
  
  // Insertar datos específicos según la planta
  Future<void> _insertPlantSpecificData(MySqlConnection conn, Report report) async {
    final String plantId = report.plant.id;
    final String reportId = report.id;
    final Map<String, dynamic> data = report.data;
    
    switch (plantId) {
      case '1': // Sulfato de Aluminio Tipo A
        await conn.query(
          '''INSERT INTO report_data_plant_1 
             (report_id, referencia, produccion_stas_1ra_reaccion, produccion_stas_2da_reaccion, produccion_liquida) 
             VALUES (?, ?, ?, ?, ?)''',
          [
            reportId,
            data['referencia'] ?? '',
            data['produccion_stas_1ra_reaccion'] ?? 0.0,
            data['produccion_stas_2da_reaccion'] ?? 0.0,
            data['produccion_liquida'] ?? 0.0,
          ],
        );
        break;
        
      case '2': // Sulfato de Aluminio Tipo B
        await conn.query(
          '''INSERT INTO report_data_plant_2 
             (report_id, reaccion_de_stbs, produccion_stbs_empaque, reaccion_de_stbl, 
              decantador_de_stbl, produccion_stbl_tanque, tanque_de_stbl) 
             VALUES (?, ?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['reaccion_de_stbs'] ?? 0,
            data['produccion_stbs_empaque'] ?? 0.0,
            data['reaccion_de_stbl'] ?? 0,
            data['decantador_de_stbl'] ?? '',
            data['produccion_stbl_tanque'] ?? 0.0,
            data['tanque_de_stbl'] ?? '',
          ],
        );
        break;
        
      case '3': // Banalum
        await conn.query(
          '''INSERT INTO report_data_plant_3 
             (report_id, referencia_reaccion, tipo_produccion, equipo_reaccion, 
              tipo_empaque, cristalizador_empaque, produccion_empaque) 
             VALUES (?, ?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['referencia_reaccion'] ?? '',
            data['tipo_produccion'] ?? '',
            data['equipo_reaccion'] ?? '',
            data['tipo_empaque'] ?? '',
            data['cristalizador_empaque'] ?? '',
            data['produccion_empaque'] ?? 0.0,
          ],
        );
        break;
        
      case '4': // Bisulfito de Sodio
        await conn.query(
          '''INSERT INTO report_data_plant_4 
             (report_id, estado_produccion, produccion_bisulfito, ph_concentrador_1, 
              densidad_concentrador_1, ph_concentrador_2, densidad_concentrador_2) 
             VALUES (?, ?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['estado_produccion'] ?? '',
            data['produccion_bisulfito'] ?? 0.0,
            data['ph_concentrador_1'] ?? 0.0,
            data['densidad_concentrador_1'] ?? 0.0,
            data['ph_concentrador_2'] ?? 0.0,
            data['densidad_concentrador_2'] ?? 0.0,
          ],
        );
        break;
        
      case '5': // Silicatos
        await conn.query(
          '''INSERT INTO report_data_plant_5 
             (report_id, referencia_reaccion, reaccion_de_silicato, produccion_de_silicato, baume, presion) 
             VALUES (?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['referencia_reaccion'] ?? '',
            data['reaccion_de_silicato'] ?? 0,
            data['produccion_de_silicato'] ?? 0.0,
            data['baume'] ?? 0.0,
            data['presion'] ?? 0.0,
          ],
        );
        break;
        
      case '6': // Policloruro de Aluminio
        await conn.query(
          '''INSERT INTO report_data_plant_6 
             (report_id, reaccion_de_cloal, produccion_cloal, densidad_cloal, 
              reaccion_de_policloruro, produccion_policloruro, densidad_policloruro) 
             VALUES (?, ?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['reaccion_de_cloal'] ?? '',
            data['produccion_cloal'] ?? 0.0,
            data['densidad_cloal'] ?? 0.0,
            data['reaccion_de_policloruro'] ?? '',
            data['produccion_policloruro'] ?? 0.0,
            data['densidad_policloruro'] ?? 0.0,
          ],
        );
        break;
        
      case '7': // Polímeros Catiónicos
        await conn.query(
          '''INSERT INTO report_data_plant_7 
             (report_id, referencia_reaccion, produccion_polimero, densidad_polimero, ph_polimero, solidos_polimero) 
             VALUES (?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['referencia_reaccion'] ?? '',
            data['produccion_polimero'] ?? 0.0,
            data['densidad_polimero'] ?? 0.0,
            data['ph_polimero'] ?? 0.0,
            data['solidos_polimero'] ?? 0.0,
          ],
        );
        break;
        
      case '8': // Polímeros Aniónicos
        await conn.query(
          '''INSERT INTO report_data_plant_8 
             (report_id, referencia_reaccion, produccion_polimero, densidad_polimero, ph_polimero, solidos_polimero) 
             VALUES (?, ?, ?, ?, ?, ?)''',
          [
            reportId,
            data['referencia_reaccion'] ?? '',
            data['produccion_polimero'] ?? 0.0,
            data['densidad_polimero'] ?? 0.0,
            data['ph_polimero'] ?? 0.0,
            data['solidos_polimero'] ?? 0.0,
          ],
        );
        break;
        
      case '9': // Llenados
        await conn.query(
          '''INSERT INTO report_data_plant_9 
             (report_id, referencia, unidades) 
             VALUES (?, ?, ?)''',
          [
            reportId,
            data['referencia'] ?? '',
            data['unidades'] ?? 0,
          ],
        );
        break;
        
      default:
        throw Exception('Planta no soportada: $plantId');
    }
  }
  
  // Obtener todos los reportes
  Future<List<Report>> getAllReports() async {
    final conn = await connection;
    
    try {
      // Obtener reportes comunes
      final results = await conn.query('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        ORDER BY r.timestamp DESC
      ''');
      
      List<Report> reports = [];
      
      // Procesar cada reporte
      for (var row in results) {
        final reportId = row['id'].toString();
        final plantId = row['plant_id'].toString();
        
        // Obtener datos específicos de cada planta
        final plantData = await _getPlantSpecificData(conn, reportId, plantId);
        
        final plant = Plant(
          id: plantId,
          name: row['plant_name'].toString(),
        );
        
        reports.add(Report(
          id: reportId,
          timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          leader: row['leader'].toString(),
          shift: row['shift'].toString(),
          plant: plant,
          data: plantData,
          notes: row['notes']?.toString(),
        ));
      }
      
      return reports;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo reportes: $e');
      }
      return [];
    }
  }
  
  // Obtener datos específicos de una planta
  Future<Map<String, dynamic>> _getPlantSpecificData(
    MySqlConnection conn, String reportId, String plantId,) async {
    try {
      final String tableName = 'report_data_plant_$plantId';
      
      // Verificar si existe la tabla
      final tableCheck = await conn.query(
        "SHOW TABLES LIKE ?",
        [tableName],
      );
      
      if (tableCheck.isEmpty) {
        if (kDebugMode) {
          print('No existe tabla para planta: $plantId');
        }
        return {};
      }
      
      // Obtener datos
      final results = await conn.query(
        "SELECT * FROM $tableName WHERE report_id = ?",
        [reportId],
      );
      
      if (results.isEmpty) return {};
      
      // Convertir a Map
      Map<String, dynamic> data = {};
      final row = results.first;
      
      // Recorrer todas las columnas excepto report_id
      for (var field in row.fields.keys) {
        if (field != 'report_id') {
          var value = row[field];
          
          // Convertir a tipo apropiado
          if (value is double || value is int) {
            data[field] = value;
          } else if (value != null) {
            data[field] = value.toString();
          }
        }
      }
      
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo datos específicos de planta $plantId: $e');
      }
      return {};
    }
  }
  
  // Obtener reportes por planta
  Future<List<Report>> getReportsByPlant(String plantId) async {
    final conn = await connection;
    
    try {
      // Obtener reportes comunes
      final results = await conn.query('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        WHERE r.plant_id = ?
        ORDER BY r.timestamp DESC
      ''', [plantId],);
      
      List<Report> reports = [];
      
      // Procesar cada reporte
      for (var row in results) {
        final reportId = row['id'].toString();
        
        // Obtener datos específicos de cada planta
        final plantData = await _getPlantSpecificData(conn, reportId, plantId);
        
        final plant = Plant(
          id: plantId,
          name: row['plant_name'].toString(),
        );
        
        reports.add(Report(
          id: reportId,
          timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          leader: row['leader'].toString(),
          shift: row['shift'].toString(),
          plant: plant,
          data: plantData,
          notes: row['notes']?.toString(),
        ));
      }
      
      return reports;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo reportes por planta: $e');
      }
      return [];
    }
  }
  
  // Obtener reportes por rango de fechas
  Future<List<Report>> getReportsByDateRange(DateTime startDate, DateTime endDate) async {
    final conn = await connection;
    
    try {
      final startMillis = startDate.millisecondsSinceEpoch;
      final endMillis = endDate.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      
      // Obtener reportes comunes
      final results = await conn.query('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        WHERE r.timestamp BETWEEN ? AND ?
        ORDER BY r.timestamp DESC
      ''', [startMillis, endMillis],);
      
      List<Report> reports = [];
      
      // Procesar cada reporte
      for (var row in results) {
        final reportId = row['id'].toString();
        final plantId = row['plant_id'].toString();
        
        // Obtener datos específicos de cada planta
        final plantData = await _getPlantSpecificData(conn, reportId, plantId);
        
        final plant = Plant(
          id: plantId,
          name: row['plant_name'].toString(),
        );
        
        reports.add(Report(
          id: reportId,
          timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
          leader: row['leader'].toString(),
          shift: row['shift'].toString(),
          plant: plant,
          data: plantData,
          notes: row['notes']?.toString(),
        ));
      }
      
      return reports;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo reportes por rango de fechas: $e');
      }
      return [];
    }
  }
  
  // Actualizar reporte
  Future<bool> updateReport(Report report) async {
    final conn = await connection;
    
    try {
      // Iniciar transacción
      await conn.query('START TRANSACTION');
      
      try {
        // 1. Actualizar datos comunes del reporte
        final result = await conn.query(
          'UPDATE reports SET leader = ?, shift = ?, plant_id = ?, notes = ? WHERE id = ?',
          [
            report.leader,
            report.shift,
            report.plant.id,
            report.notes,
            report.id,
          ],
        );
        
        if (result.affectedRows! <= 0) {
          throw Exception('No se pudo actualizar el reporte');
        }
        
        // 2. Eliminar datos específicos existentes
        final tableName = 'report_data_plant_${report.plant.id}';
        await conn.query(
          'DELETE FROM $tableName WHERE report_id = ?',
          [report.id],
        );
        
        // 3. Insertar nuevos datos específicos
        await _insertPlantSpecificData(conn, report);
        
        // Confirmar transacción
        await conn.query('COMMIT');
        return true;
      } catch (e) {
        // Revertir transacción en caso de error
        await conn.query('ROLLBACK');
        if (kDebugMode) {
          print('Error en transacción de actualización: $e');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error actualizando reporte: $e');
      }
      return false;
    }
  }
  
  // Eliminar reporte
  Future<bool> deleteReport(String reportId) async {
    final conn = await connection;
    
    try {
      // No es necesaria una transacción explícita por el ON DELETE CASCADE
      final result = await conn.query(
        'DELETE FROM reports WHERE id = ?',
        [reportId],
      );
      
      return result.affectedRows! > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error eliminando reporte: $e');
      }
      return false;
    }
  }
  
  // EXPORTACIÓN
  
  // Exportar reportes a CSV
  Future<String?> exportReportsToCSV() async {
    // Implementar lógica para generar CSV con los datos
    // Este proceso debería hacerse en el servidor para bases de datos grandes
    
    try {
      final reports = await getAllReports();
      
      // Construir el CSV (simplificado)
      StringBuffer csv = StringBuffer();
      
      // Encabezados
      csv.writeln('ID,Fecha,Líder,Turno,Planta,Notas');
      
      // Datos
      for (var report in reports) {
        csv.writeln(
          '${report.id},${report.timestamp.toIso8601String()},${report.leader},'
          '${report.shift},${report.plant.name},"${report.notes ?? ''}"',
        );
      }
      
      return csv.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error exportando a CSV: $e');
      }
      return null;
    }
  }
  
  // Exportar reportes a JSON
  Future<String?> exportReportsToJSON() async {
    try {
      final reports = await getAllReports();
      
      // Convertir a JSON
      List<Map<String, dynamic>> jsonData = reports.map((report) => {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'plant_name': report.plant.name,
        'data': report.data,
        'notes': report.notes,
      }).toList();
      
      return jsonEncode(jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error exportando a JSON: $e');
      }
      return null;
    }
  }
}