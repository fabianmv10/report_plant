// lib/config/api_config.dart
class ApiConfig {
  // URL base de la API
  static const String baseUrl = 'https://tu-servidor-api.com/api';
  
  // Timeouts
  static const int connectTimeout = 10; // segundos
  static const int receiveTimeout = 10; // segundos
  
  // Configuración de autenticación
  static bool requiresAuth = true;
  
  // Endpoints
  static const String login = '/auth/login';
  static const String plants = '/plants';
  static const String reports = '/reports';
  static const String exportCSV = '/export/csv';
  static const String exportJSON = '/export/json';
}