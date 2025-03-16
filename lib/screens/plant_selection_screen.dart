import 'package:flutter/material.dart';
import '../models/report.dart';

class PlantSelectionScreen extends StatelessWidget {
  const PlantSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de plantas de ejemplo (luego vendría de base de datos)
    final plants = [
      Plant(id: '1', name: 'Sulfato de Aluminio Tipo A'),
      Plant(id: '2', name: 'Sulfato de Aluminio Tipo B'),
      Plant(id: '3', name: 'Banalum'),
      Plant(id: '4', name: 'Bisulfito de Sodio'),
      Plant(id: '5', name: 'Silicatos'),
      Plant(id: '6', name: 'Policloruro de Aluminio'),
      Plant(id: '7', name: 'Polímeros Catiónicos'),
      Plant(id: '8', name: 'Polímeros Aniónicos'),
      Plant(id: '9', name: 'Llenados')
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Planta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: plants.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(plants[index].name),
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    '/new_report',
                    arguments: plants[index],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}