import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

/// Proveedor del tema para la aplicación
/// Permite cambiar entre tema claro y oscuro y persistir la selección
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Cargar el modo de tema desde las preferencias
  Future<void> _loadThemeMode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString != null) {
        _themeMode = themeModeString == 'dark' 
            ? ThemeMode.dark 
            : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando el modo de tema: $e');
    }
  }

  /// Guardar el modo de tema en las preferencias
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      // ignore: avoid_print
      print('Error guardando el modo de tema: $e');
    }
  }

  /// Cambiar a tema oscuro
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveThemeMode(_themeMode);
    notifyListeners();
  }

  /// Cambiar a tema claro
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveThemeMode(_themeMode);
    notifyListeners();
  }

  /// Alternar entre tema claro y oscuro
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await _saveThemeMode(_themeMode);
    notifyListeners();
  }

  /// Obtener el tema actual
  ThemeData get currentTheme => 
      _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
      
  /// Verificar si está usando el tema oscuro
  bool get isDarkMode => _themeMode == ThemeMode.dark;
}