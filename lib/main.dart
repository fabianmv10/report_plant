import 'package:flutter/material.dart';
import 'models/report.dart';
import 'screens/home_screen.dart';
import 'screens/new_report_screen.dart';
import 'screens/plant_selection_screen.dart';
import 'services/database_helper.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // Necesario para operaciones asíncronas en main
  
  final app = MyApp();
  await app._initializeDefaultPlants();
  runApp(app);
  
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeDefaultPlants() async {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reportes de Turno',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      routes: {
        '/plant_selection': (context) => const PlantSelectionScreen(),
        '/new_report': (context) => NewReportScreen(
          plant: ModalRoute.of(context)!.settings.arguments as Plant,
        ),
      },
    );
  }
}