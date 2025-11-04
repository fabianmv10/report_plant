// ignore_for_file: inference_failure_on_instance_creation

import 'package:flutter/material.dart';
import 'plant_selection_screen.dart';
import 'report_list_screen.dart';
import 'settings_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/responsive_layout.dart';
import '../theme/theme.dart';

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
      padding: const EdgeInsets.all(AppTheme.mediumSpacing),
      child: _buildNavigationGrid(context, crossAxisCount: 2),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.mediumSpacing,
              bottom: AppTheme.mediumSpacing,
            ),
            child: Text(
              'Panel de Control',
              style: context.textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: _buildNavigationGrid(context, crossAxisCount: 3),
          ),
        ],
      ),
    );
  }

  // ignore: avoid-unused-parameters
  Widget _buildNavigationGrid(BuildContext context, {required int crossAxisCount}) {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Nuevo Reporte',
        'icon': Icons.add_circle,
        'color': AppTheme.primaryColor,
        'route': 'new_report',
      },
      {
        'title': 'Ver Reportes',
        'icon': Icons.list_alt,
        'color': AppTheme.secondaryColor,
        'route': 'report_list',
      },
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'color': AppTheme.primaryColorDark,
        'route': 'dashboard',
      },
      {
        'title': 'Configuración',
        'icon': Icons.settings,
        'color': AppTheme.secondaryColorDark,
        'route': 'settings',
      },
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.mediumBorderRadius,
          ),
          child: InkWell(
            borderRadius: AppTheme.mediumBorderRadius,
            onTap: () => _navigateTo(context, option['route'] as String),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppTheme.mediumBorderRadius,
                gradient: LinearGradient(
                  colors: [option['color'] as Color, (option['color'] as Color).withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option['icon'] as IconData?,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    Text(
                      option['title'] as String,
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