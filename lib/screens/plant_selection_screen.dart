import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../theme/theme.dart';
import 'new_report_screen.dart';

class PlantSelectionScreen extends StatelessWidget {
  const PlantSelectionScreen({super.key});

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Función para obtener un color basado en el ID de la planta
  Color getPlantColor(String id) {
    // Usar colores del tema
    return AppTheme.plantColors[id] ?? AppTheme.primaryColor;
  }

  // Función para obtener un icono basado en el ID de la planta
  IconData getPlantIcon(String id) {
    switch (id) {
      case '1': return Icons.water_drop;
      case '2': return Icons.water_drop;
      case '3': return Icons.agriculture;
      case '4': return Icons.science;
      case '5': return Icons.bubble_chart;
      case '6': return Icons.factory;
      case '7': return Icons.polymer;
      case '8': return Icons.polymer;
      case '9': return Icons.inventory;
      default: return Icons.spa;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Planta'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PlantsBloc>().add(const PlantsEvent.refreshPlants());
            },
          ),
        ],
      ),
      body: BlocConsumer<PlantsBloc, PlantsState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) => _showErrorSnackBar(context, message),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (plants) => plants.isEmpty
                ? _buildEmptyState()
                : _buildPlantGrid(plants),
            error: (message) => _buildErrorState(context, message),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(
            'Error al cargar plantas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PlantsBloc>().add(const PlantsEvent.loadPlants());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textHintColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No hay plantas disponibles'
                : 'No se encontraron plantas para "$_searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlantGrid(List<Plant> plants) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        final color = getPlantColor(plant.id);
        final icon = getPlantIcon(plant.id);
        
        return _buildPlantCard(plant, color, icon);
      },
    );
  }
  
  Widget _buildPlantCard(Plant plant, Color color, IconData icon) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Builder(
        builder: (context) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewReportScreen(plant: plant),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      plant.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}