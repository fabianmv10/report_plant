import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_helper.dart';

class PlantSelectionScreen extends StatelessWidget {
  const PlantSelectionScreen({super.key});

  // Función para obtener un color basado en el ID de la planta
  Color getPlantColor(String id) {
    // Diferentes colores según el ID para diferenciar las plantas
    switch (id) {
      case '1': return Colors.blue[600]!;
      case '2': return Colors.green[600]!;
      case '3': return Colors.amber[700]!;
      case '4': return Colors.red[600]!;
      case '5': return Colors.purple[600]!;
      case '6': return Colors.teal[600]!;
      case '7': return Colors.indigo[600]!;
      case '8': return Colors.deepOrange[600]!;
      case '9': return Colors.brown[600]!;
      default: return Colors.blue[600]!;
    }
  }

  // Función para obtener un icono basado en el ID de la planta
  IconData getPlantIcon(String id) {
    switch (id) {
      case '1': return Icons.water_drop;
      case '2': return Icons.water_drop;
      case '3': return Icons.agriculture;
      case '4': return Icons.pages;
      case '5': return Icons.factory;
      case '6': return Icons.factory;
      case '7': return Icons.polymer;
      case '8': return Icons.polymer;
      case '9': return Icons.inventory;
      default: return Icons.spa;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las plantas de la base de datos
    Future<List<Plant>> getPlants() async {
      return await DatabaseHelper.instance.getAllPlants();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Planta'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Plant>>(
        future: getPlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay plantas disponibles'));
          }
          
          final plants = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final color = getPlantColor(plant.id);
                final icon = getPlantIcon(plant.id);
                
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/new_report',
                        arguments: plant,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              plant.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}