import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';
import '../services/api_client.dart';
import '../services/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;
  int _pendingReportsCount = 0;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _getPendingReportsCount();
  }

  Future<void> _checkConnection() async {
    final connected = await ApiClient.instance.checkStatus();
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  Future<void> _getPendingReportsCount() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM reports WHERE synced = 0',
    )) ?? 0;
    
    if (mounted) {
      setState(() {
        _pendingReportsCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferencias de la aplicación',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.mediumSpacing),
            
            // Sección de configuración del tema
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Modo oscuro'),
                    subtitle: Text(
                      'Cambiar apariencia de la aplicación',
                      style: context.textTheme.bodySmall,
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (bool value) {
                      if (value) {
                        themeProvider.setDarkMode();
                      } else {
                        themeProvider.setLightMode();
                      }
                    },
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.mediumSpacing),
            
            // Sección de sincronización
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Estado de conexión'),
                    subtitle: Text(
                      _isConnected 
                        ? 'Conectado al servidor' 
                        : 'Sin conexión al servidor',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    leading: Icon(
                      _isConnected ? Icons.cloud_done : Icons.cloud_off,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        await _checkConnection();
                        await _getPendingReportsCount();
                      },
                      tooltip: 'Verificar conexión',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Sincronización de datos'),
                    subtitle: Text(
                      _pendingReportsCount > 0
                          ? 'Hay $_pendingReportsCount reporte${_pendingReportsCount > 1 ? 's' : ''} pendiente${_pendingReportsCount > 1 ? 's' : ''} por sincronizar'
                          : 'Todos los datos están sincronizados',
                      style: TextStyle(
                        color: _pendingReportsCount > 0 ? AppTheme.warningColor : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                    leading: Icon(
                      _pendingReportsCount > 0 ? Icons.sync_problem : Icons.sync,
                      color: _pendingReportsCount > 0 ? AppTheme.warningColor : context.primaryColor,
                    ),
                    trailing: _isSyncing
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.sync),
                          onPressed: _syncData,
                          tooltip: 'Sincronizar datos',
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.mediumSpacing),
            
            // Información de la aplicación
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Versión de la aplicación'),
                    subtitle: Text(
                      'Información del sistema',
                      style: context.textTheme.bodySmall,
                    ),
                    leading: Icon(
                      Icons.info_outline,
                      color: context.primaryColor,
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Acerca de'),
                    subtitle: Text(
                      'Información sobre la aplicación',
                      style: context.textTheme.bodySmall,
                    ),
                    leading: Icon(
                      Icons.help_outline,
                      color: context.primaryColor,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            Center(
              child: Text(
                '© 2025 PQP - Reportes de Turno',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    
    setState(() {
      _isSyncing = true;
    });
    
    try {
      // Mostrar diálogo de sincronización
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronizando datos...'),
            duration: Duration(milliseconds: 800),
          ),
        );
      }
      
      // Ejecutar sincronización
      final result = await _performSync();
      
      // Actualizar conteo de reportes pendientes
      await _getPendingReportsCount();
      
      // Mostrar resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] 
                ? 'Sincronización completada: ${result['syncedCount']} reporte(s) sincronizado(s)'
                : 'Error en la sincronización: ${result['error'] ?? "Revise su conexión"}',
            ),
            backgroundColor: result['success'] ? AppTheme.successColor : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _performSync() async {
    try {
      // Contar reportes pendientes antes
      final db = await DatabaseHelper.instance.database;
      final pendingBefore = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM reports WHERE synced = 0',
      )) ?? 0;
      
      // Sincronizar reportes pendientes
      final success = await DatabaseHelper.instance.syncPendingReports();
      
      // Contar reportes pendientes después
      final pendingAfter = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM reports WHERE synced = 0',
      )) ?? 0;
      
      // Actualizar plantas desde el servidor
      List<dynamic> remotePlants = [];
      bool plantsSuccess = false;
      
      try {
        remotePlants = await ApiClient.instance.getAllPlants();
        plantsSuccess = remotePlants.isNotEmpty;
      } catch (e) {
        plantsSuccess = false;
      }
      
      // Verificar conexión nuevamente
      await _checkConnection();
      
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Reportes de Turno',
        applicationVersion: '1.0.0',
        applicationIcon: Icon(
          Icons.assignment,
          color: context.primaryColor,
          size: 48,
        ),
        children: const [
          SizedBox(height: 16),
          Text(
            'Aplicación para gestión de reportes de turno en plantas de producción.',
          ),
          SizedBox(height: 8),
          Text(
            'Desarrollado con Flutter.',
          ),
        ],
      ),
    );
  }
}