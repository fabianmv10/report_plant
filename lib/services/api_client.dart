// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/report.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._init();
  
  // Configuración de la API (ajusta la IP a tu servidor)
  final String baseUrl = 'http://192.168.97.192:3000/api';
  final Duration timeout = const Duration(seconds: 30);
  
  ApiClient._init();
  
  // Método para verificar el estado de la API
  Future<bool> checkStatus() async {
    try {
      print('Intentando conectar a: $baseUrl/status');
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
      ).timeout(timeout);
      
      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'online';
      }
      return false;
    } catch (e) {
      print('Error detallado en checkStatus: $e');
      return false;
    }
  }
  
  // ===== PLANTAS =====
  
  Future<List<Plant>> getAllPlants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plants'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => Plant(
          id: json['id'].toString(),
          name: json['name'].toString(),
        )).toList();
      } else {
        print('Error API: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener plantas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAllPlants: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  Future<bool> insertPlant(Plant plant) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/plants'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': plant.id,
          'name': plant.name,
        }),
      ).timeout(timeout);
      
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en insertPlant: $e');
      return false;
    }
  }
  
  // ===== REPORTES =====
  
  Future<List<Report>> getAllReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) {
          final plant = Plant(
            id: json['plant_id'].toString(),
            name: json['plant_name'].toString(),
          );

          // Convertir los datos específicos
          Map<String, dynamic> reportData = {};
          if (json['data'] != null) {
            reportData = Map<String, dynamic>.from(json['data'] as Map<dynamic, dynamic>);
          }

          return Report(
            id: json['id'].toString(),
            timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
            leader: json['leader'].toString(),
            shift: json['shift'].toString(),
            plant: plant,
            data: reportData,
            notes: json['notes'] as String?,
          );
        }).toList();
      } else {
        print('Error API: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAllReports: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  Future<bool> insertReport(Report report) async {
    try {
      // Preparar los datos para la API
      final Map<String, dynamic> payload = {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': report.data,
        'notes': report.notes,
      };
      
      print('⚠️ Enviando reporte a API: ${report.id} - Planta: ${report.plant.id}');
      print('📦 Datos: ${jsonEncode(payload)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(timeout);
      
      print('📡 Respuesta de API: ${response.statusCode}');
      print('📄 Contenido: ${response.body}');
      
      if (response.statusCode == 201) {
        return true;
      } else {
        print('❌ Error API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> diagnoseConnection() async {
    try {
      final statusUrlTest = Uri.parse('$baseUrl/status');
      final plantsUrlTest = Uri.parse('$baseUrl/plants');
      
      print('Probando conexión a: $statusUrlTest');
      final statusResponse = await http.get(statusUrlTest).timeout(timeout);
      
      print('Probando conexión a: $plantsUrlTest');
      final plantsResponse = await http.get(plantsUrlTest).timeout(timeout);
      
      return {
        'success': true,
        'statusCode': statusResponse.statusCode,
        'statusBody': statusResponse.body,
        'plantsCode': plantsResponse.statusCode,
        'plantsBodySample': plantsResponse.body.substring(0, min(100, plantsResponse.body.length)),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}