import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';

/// Migraciones de base de datos
/// Cada migración debe tener un número de versión único
class DatabaseMigrations {
  /// Obtener migración para una versión específica
  static Future<void> Function(Database)? getMigration(int version) {
    switch (version) {
      case 2:
        return _migrationV2;
      // Agregar más migraciones aquí según sea necesario
      default:
        return null;
    }
  }

  /// Migración a versión 2: Agregar campos created_at y updated_at
  static Future<void> _migrationV2(Database db) async {
    logger.info('Aplicando migración v2');

    // Verificar si las columnas ya existen
    final tableInfo = await db.rawQuery('PRAGMA table_info(reports)');
    final columnNames = tableInfo.map((col) => col['name']).toList();

    if (!columnNames.contains('created_at')) {
      await db.execute('''
        ALTER TABLE reports
        ADD COLUMN created_at INTEGER DEFAULT 0
      ''');
    }

    if (!columnNames.contains('updated_at')) {
      await db.execute('''
        ALTER TABLE reports
        ADD COLUMN updated_at INTEGER DEFAULT 0
      ''');
    }

    // Actualizar registros existentes
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.execute('''
      UPDATE reports
      SET created_at = ?, updated_at = ?
      WHERE created_at = 0
    ''', [now, now]);

    logger.info('Migración v2 completada');
  }

  /// Ejemplo de migración futura v3
  static Future<void> _migrationV3(Database db) async {
    logger.info('Aplicando migración v3');

    // Ejemplo: Agregar tabla de configuraciones
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    logger.info('Migración v3 completada');
  }
}
