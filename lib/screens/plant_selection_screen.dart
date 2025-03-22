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
  String _searchQuery = '';
  
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
  
  // Describe cada planta con un texto informativo
  String getPlantDescription(String id) {
    switch (id) {
      case '1': return 'Planta de producción de sulfato de aluminio tipo A';
      case '2': return 'Planta de producción de sulfato de aluminio tipo B';
      case '3': return 'Línea de producción de Banalum';
      case '4': return 'Producción de bisulfito de sodio';
      case '5': return 'Producción de silicatos';
      case '6': return 'Producción de policloruro de aluminio';
      case '7': return 'Línea de polímeros catiónicos';
      case '8': return 'Línea de polímeros aniónicos';
      case '9': return 'Área de llenado y envasado';
      default: return 'Planta de producción';
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
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar planta...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        final color = getPlantColor(plant.id);
        final icon = getPlantIcon(plant.id);
        final description = getPlantDescription(plant.id);
        
        return _buildPlantCard(plant, color, icon, description);
      },
    );
  }
  
  Widget _buildPlantCard(Plant plant, Color color, IconData icon, String description) {
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
        child: Column(
          children: [
            // Cabecera con color e icono
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      plant.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Botón
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/new_report',
                    arguments: plant,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Seleccionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}