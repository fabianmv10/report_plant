import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/report.dart';
import 'screens/home_screen.dart';
import 'screens/new_report_screen.dart';
import 'screens/plant_selection_screen.dart';
import 'services/database_helper.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para operaciones asíncronas en main
  
  //await initializeDefaultPlants();

  // Intentar sincronizar reportes pendientes
  await DatabaseHelper.instance.syncPendingReports();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
} 

Future<void> initializeDefaultPlants() async {
  final plants = [
    Plant(id: '1', name: 'Sulfato de Aluminio Tipo A'),
    Plant(id: '2', name: 'Sulfato de Aluminio Tipo B'),
    Plant(id: '3', name: 'Banalum'),
    Plant(id: '4', name: 'Bisulfito de Sodio'),
    Plant(id: '5', name: 'Silicatos'),
    Plant(id: '6', name: 'Policloruro de Aluminio'),
    Plant(id: '7', name: 'Polímeros Catiónicos'),
    Plant(id: '8', name: 'Polímeros Aniónicos'),
    Plant(id: '9', name: 'Llenados'),
  ];
  
  // Obtener plantas existentes
  final existingPlants = await DatabaseHelper.instance.getAllPlants();
  final existingIds = existingPlants.map((p) => p.id).toSet();

  // Insertar solo las plantas que no existen
  for (var plant in plants) {
    if (!existingIds.contains(plant.id)) {
      await DatabaseHelper.instance.insertPlant(plant);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Reportes de Turno',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
          routes: {
            '/plant_selection': (context) => const PlantSelectionScreen(),
            '/new_report': (context) => NewReportScreen(
              plant: ModalRoute.of(context)!.settings.arguments as Plant,
            ),
          },
        );
      },
    );
  }
}
