import 'package:flutter/material.dart';
import 'plant_selection_screen.dart';
import 'report_list_screen.dart';
import 'settings_screen.dart';
import 'dashboard_screen.dart'; // Nueva pantalla que crearemos
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

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildNavigationGrid(context, crossAxisCount: 2),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _buildNavigationGrid(context, crossAxisCount: 3),
    );
  }

  Widget _buildNavigationGrid(BuildContext context, {required int crossAxisCount}) {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Nuevo Reporte',
        'icon': Icons.add_circle,
        'color': Colors.blue[600]!,
        'route': 'new_report',
      },
      {
        'title': 'Ver Reportes',
        'icon': Icons.list_alt,
        'color': Colors.green[600]!,
        'route': 'report_list',
      },
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'color': Colors.orange[600]!,
        'route': 'dashboard',
      },
      {
        'title': 'Configuración',
        'icon': Icons.settings,
        'color': Colors.purple[600]!,
        'route': 'settings',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateTo(context, option['route']),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [option['color'], option['color'].withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option['icon'],
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      option['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, String screenName) {
    if (screenName == 'new_report') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlantSelectionScreen()),
      );
    } else if (screenName == 'report_list') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportListScreen()),
      );
    } else if (screenName == 'dashboard') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (screenName == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }
}