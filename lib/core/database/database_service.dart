import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/logger.dart';
import 'migrations.dart';

/// Servicio centralizado de base de datos con soporte para migraciones
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _databaseName = 'reports_app.db';
  static const int _databaseVersion = 2; // Incrementar cuando hay migraciones

  Database? _database;

  /// Obtener instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializar base de datos
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);

      logger.info('Inicializando base de datos en: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      );
    } catch (e) {
      logger.error('Error al inicializar base de datos', e);
      rethrow;
    }
  }

  /// Crear base de datos (primera vez)
  Future<void> _onCreate(Database db, int version) async {
    logger.info('Creando base de datos versión $version');

    await db.execute('''
      CREATE TABLE plants(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        last_synced INTEGER
      )
    ''');

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
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (plant_id) REFERENCES plants (id) ON DELETE CASCADE
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('''
      CREATE INDEX idx_reports_plant_id ON reports(plant_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reports_timestamp ON reports(timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_reports_synced ON reports(synced)
    ''');

    // Tabla para tokens de autenticación
    await db.execute('''
      CREATE TABLE auth_tokens(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        access_token TEXT NOT NULL,
        token_type TEXT NOT NULL,
        expires_in INTEGER NOT NULL,
        refresh_token TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    logger.info('Base de datos creada exitosamente');
  }

  /// Actualizar base de datos (migraciones)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    logger.info('Actualizando base de datos de v$oldVersion a v$newVersion');

    // Ejecutar migraciones incrementales
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      logger.info('Aplicando migración a versión $version');

      final migration = DatabaseMigrations.getMigration(version);
      if (migration != null) {
        await migration(db);
      }
    }

    logger.info('Migración completada');
  }

  /// Degradar base de datos (rollback)
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    logger.warning('Degradando base de datos de v$oldVersion a v$newVersion');
    // Implementar lógica de downgrade si es necesario
  }

  /// Cerrar base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    logger.info('Base de datos cerrada');
  }

  /// Eliminar base de datos (para testing o reset)
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      logger.info('Base de datos eliminada');
    } catch (e) {
      logger.error('Error al eliminar base de datos', e);
      rethrow;
    }
  }

  /// Obtener información de la base de datos
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final version = await db.getVersion();
    final path = db.path;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    return {
      'version': version,
      'path': path,
      'tables': tables.map((t) => t['name']).toList(),
    };
  }
}
