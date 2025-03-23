import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../theme/theme.dart';

class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({super.key});

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  bool _isLoading = true;
  List<Plant> _plants = [];
  final String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadPlants();
  }
  
  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final plants = await DatabaseHelper.instance.getAllPlants();
      setState(() {
        _plants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al cargar plantas: $e');
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
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
    // Filtrar plantas según la búsqueda
    final filteredPlants = _searchQuery.isEmpty
        ? _plants
        : _plants.where((plant) => 
            plant.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
            
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Planta'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Lista de plantas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPlants.isEmpty
                    ? _buildEmptyState()
                    : _buildPlantGrid(filteredPlants),
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
      clipBehavior: Clip.antiAlias, // Esto asegura que el gradiente no sobresalga de las esquinas
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context, 
            '/new_report',
            arguments: plant,
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
    );
  }
}