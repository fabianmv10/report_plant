import 'package:flutter/material.dart';
import 'plant_selection_screen.dart';
import 'report_list_screen.dart';
import 'settings_screen.dart';
import '../widgets/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Turno'),
      ),
      body: ResponsiveLayout(
        mobileLayout: _buildMobileLayout(context),
        tabletLayout: _buildTabletLayout(context),
      ),
    );
  }

  //Configuración de vista para Telefono, con los llamados para las diferentes pantallas
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNavButton(
            context, 
            'Nuevo Reporte', 
            Icons.add_circle, 
            'new_report'
          ),
          const SizedBox(height: 16),
          _buildNavButton(
            context, 
            'Ver Reportes', 
            Icons.list_alt, 
            'report_list'
          ),
          const SizedBox(height: 16),
          _buildNavButton(
            context, 
            'Configuración', 
            Icons.settings, 
            'settings'
          ),
        ],
      ),
    );
  }

  //Configuración de vista para Tablet, con los llamados para las diferentes pantallas
  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildNavCard(
            context, 
            'Nuevo Reporte', 
            Icons.add_circle, 
            'new_report'
          ),
          _buildNavCard(
            context, 
            'Ver Reportes', 
            Icons.list_alt, 
            'report_list'
          ),
          _buildNavCard(
            context, 
            'Configuración', 
            Icons.settings, 
            'settings'
          ),
        ],
      ),
    );
  }

  //Configuración de cada boton presente en la pantalla principal.
  Widget _buildNavButton(
    BuildContext context, String title, IconData icon, String routeName) {
  return ElevatedButton(
    onPressed: () => _navigateTo(context, routeName),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18)),
      ],
    ),
  );
}

  //Configuración de cada tarjeta presente en la pantalla principal.
  Widget _buildNavCard(
      BuildContext context, String title, IconData icon, String routeName) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateTo(context, routeName),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  //Permite abrir la siguiente pantalla segun la configuración.
  void _navigateTo(BuildContext context, String screenName) {
    if (screenName == 'new_report') {
      // Para nuevo reporte, primero ir a selección de planta
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlantSelectionScreen()),
      );
    } else if (screenName == 'report_list') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportListScreen()),
      );
    } else if (screenName == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }
}