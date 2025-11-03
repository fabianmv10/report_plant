import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración centralizada de la aplicación
class AppConfig {
  // Singleton
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// Inicializar la configuración cargando variables de entorno
  static Future<void> initialize({String envFile = '.env'}) async {
    await dotenv.load(fileName: envFile);
  }

  // API Configuration
  String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost:3000/api');
  int get apiTimeoutSeconds => int.parse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '30'));

  // Auth Configuration
  bool get requireAuth => dotenv.get('REQUIRE_AUTH', fallback: 'false').toLowerCase() == 'true';
  String get jwtSecret => dotenv.get('JWT_SECRET', fallback: '');

  // Logging Configuration
  String get logLevel => dotenv.get('LOG_LEVEL', fallback: 'info');
  bool get enableCrashReporting => dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'false').toLowerCase() == 'true';

  // Feature Flags
  bool get enableOfflineMode => dotenv.get('ENABLE_OFFLINE_MODE', fallback: 'true').toLowerCase() == 'true';
  bool get enableExport => dotenv.get('ENABLE_EXPORT', fallback: 'true').toLowerCase() == 'true';

  /// Obtener configuración completa como Map
  Map<String, dynamic> toMap() {
    return {
      'apiBaseUrl': apiBaseUrl,
      'apiTimeoutSeconds': apiTimeoutSeconds,
      'requireAuth': requireAuth,
      'logLevel': logLevel,
      'enableCrashReporting': enableCrashReporting,
      'enableOfflineMode': enableOfflineMode,
      'enableExport': enableExport,
    };
  }
}
