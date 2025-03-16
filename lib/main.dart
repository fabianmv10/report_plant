import 'package:flutter/material.dart';
import 'models/report.dart';
import 'screens/home_screen.dart';
import 'screens/new_report_screen.dart';
import 'screens/plant_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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