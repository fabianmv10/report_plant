import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Español';
  final List<String> _languages = ['Español', 'English'];

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
                  const Divider(),
                  ListTile(
                    title: const Text('Idioma'),
                    subtitle: Text(
                      'Cambiar el idioma de la interfaz',
                      style: context.textTheme.bodySmall,
                    ),
                    leading: Icon(
                      Icons.language,
                      color: context.primaryColor,
                    ),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 4,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                      },
                      items: _languages.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.mediumSpacing),
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
                '© 2023 Reportes de Turno',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
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