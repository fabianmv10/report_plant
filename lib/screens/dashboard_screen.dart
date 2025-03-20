import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../widgets/responsive_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _singleDashboardKey = GlobalKey();
  bool _isLoading = false;
  bool _preparingExport = false;
  DateTime _selectedDate = DateTime.now();
  List<Report> _reports = [];
  Map<String, List<Report>> _reportsByPlant = {};
  List<String> _shifts = ['Mañana', 'Tarde', 'Noche'];
  
  // Para navegación entre plantas
  int _currentPlantIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Método optimizado para cargar datos
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar todos los reportes
      final allReports = await DatabaseHelper.instance.getAllReports();
      
      // Filtrar reportes por la fecha seleccionada
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      _reports = allReports.where((report) => 
        report.timestamp.isAfter(startOfDay) && 
        report.timestamp.isBefore(endOfDay)
      ).toList();
      
      // Agrupar reportes por planta
      _reportsByPlant = {};
      for (var report in _reports) {
        _reportsByPlant.putIfAbsent(report.plant.name, () => []).add(report);
      }
      
      // Ordenar plantas por número de reportes (descendente)
      var sortedPlants = _reportsByPlant.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));
      
      // Reconstruir el mapa ordenado
      _reportsByPlant = Map.fromEntries(sortedPlants);
      
      // Resetear índice si es necesario
      if (_reportsByPlant.isEmpty) {
        _currentPlantIndex = 0;
      } else if (_currentPlantIndex >= _reportsByPlant.length) {
        _currentPlantIndex = 0;
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para mostrar errores de manera centralizada
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDashboardData();
    }
  }

  void _nextPlant() {
    if (_reportsByPlant.isNotEmpty) {
      setState(() {
        _currentPlantIndex = (_currentPlantIndex + 1) % _reportsByPlant.length;
      });
    }
  }

  void _previousPlant() {
    if (_reportsByPlant.isNotEmpty) {
      setState(() {
        _currentPlantIndex = (_currentPlantIndex - 1 + _reportsByPlant.length) % _reportsByPlant.length;
      });
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Dashboard'),
        content: const Text('¿Qué información desea exportar?'),
        actions: [
          TextButton(
            child: const Text('Planta actual'),
            onPressed: () {
              Navigator.of(context).pop();
              _captureSingleDashboard();
            },
          ),
          ElevatedButton(
            child: const Text('Todas las plantas'),
            onPressed: () {
              Navigator.of(context).pop();
              _captureConsolidatedDashboard();
            },
          ),
        ],
      ),
    );
  }

  // Captura una sola planta
  Future<void> _captureSingleDashboard() async {
    try {
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary = 
          _singleDashboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        _shareDashboardImage(pngBytes, 'single');
      }
    } catch (e) {
      _showErrorSnackBar('Error al exportar: $e');
    }
  }

  // Método optimizado para capturar el dashboard consolidado
  Future<void> _captureConsolidatedDashboard() async {
    if (_reportsByPlant.isEmpty) {
      _showErrorSnackBar('No hay datos para exportar');
      return;
    }

    setState(() {
      _preparingExport = true;
    });
    
    try {
      // Crear escena de captura fuera de pantalla
      await _captureConsolidatedContent();
    } catch (e) {
      _showErrorSnackBar('Error al exportar: $e');
    } finally {
      setState(() {
        _preparingExport = false;
      });
    }
  }

  // Método separado para la captura de contenido consolidado
  Future<void> _captureConsolidatedContent() async {
    final tempKey = GlobalKey();
    final content = _buildExportContent();
    
    // Crear un overlay para renderizar el contenido fuera de la vista
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -4000, // Fuera de la pantalla
        child: Material(
          child: RepaintBoundary(
            key: tempKey,
            child: content,
          ),
        ),
      ),
    );

    // Insertar en el overlay y esperar a que se renderice
    overlayState.insert(overlayEntry);
    
    try {
      // Esperar a que se renderice el contenido
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Capturar la imagen
      final RenderRepaintBoundary? boundary = 
          tempKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception('No se pudo obtener el contexto para la captura');
      }
      
      // Mayor valor de pixelRatio para mejorar la nitidez del texto
      final ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('No se pudieron obtener los datos de la imagen');
      }
      
      // Compartir la imagen
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      await _shareDashboardImage(pngBytes, 'consolidated');
    } finally {
      // Asegurarse de eliminar el overlay
      overlayEntry.remove();
    }
  }

  // Widget para construir la vista de exportación
  Widget _buildExportContent() {
    // Establecer un formato de 3 columnas como solicitado
    const int fixedColumns = 3;
    
    // Ancho fijo para cada planta (reducido para acomodar 3 columnas)
    const double plantWidth = 280.0;
    
    // Ancho total
    final double totalWidth = plantWidth * fixedColumns + 48; // Incluir padding
    
    // Calcular número de filas necesarias
    final int totalPlants = _reportsByPlant.length;
    final int rows = (totalPlants / fixedColumns).ceil();
    
    // Convertir el mapa a una lista para facilitar el acceso
    final plantList = _reportsByPlant.entries.toList();
    
    return Container(
      width: totalWidth,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          _buildExportHeader(),
          const SizedBox(height: 20),

          // Contenido en filas
          ...List.generate(rows, (rowIndex) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(fixedColumns, (colIndex) {
                    final int index = rowIndex * fixedColumns + colIndex;
                    if (index < plantList.length) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: colIndex < fixedColumns - 1 ? 8 : 0, // Reducido el padding horizontal
                          bottom: 16,
                        ),
                        child: SizedBox(
                          width: plantWidth,
                          child: _buildPlantCard(plantList[index]),
                        ),
                      );
                    } else {
                      return SizedBox(width: plantWidth);
                    }
                  }),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Widget para el encabezado del reporte exportado
  Widget _buildExportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'REPORTE CONSOLIDADO DE PRODUCCIÓN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget mejorado para mostrar la tarjeta de una planta
  Widget _buildPlantCard(MapEntry<String, List<Report>> entry) {
    if (entry.key.isEmpty) return Container(height: 1);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la planta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              entry.key,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Turnos para esta planta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0), // Reducido el padding horizontal
            child: Column(
              children: _shifts.map((shift) {
                final shiftReports = entry.value.where((r) => r.shift == shift).toList();
                if (shiftReports.isEmpty) return Container();
                
                return _buildShiftCard(shift, shiftReports);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget separado para mostrar información de un turno
  Widget _buildShiftCard(String shift, List<Report> shiftReports) {
    // Colores para los turnos
    final shiftColors = {
      'Mañana': Colors.amber[700],
      'Tarde': Colors.blue[700],
      'Noche': Colors.indigo[700],
    };
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: shiftColors[shift] ?? Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del turno
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: shiftColors[shift]?.withOpacity(0.2),
            child: Text(
              'Turno: $shift',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: shiftColors[shift],
              ),
            ),
          ),
          
          // Datos de producción
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Producción:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Reducido para mejor ajuste
                  ),
                ),
                const SizedBox(height: 4),
                
                // Datos de producción con mejor formato
                _buildProductionDataList(shiftReports.first),
                
                // Novedades si existen
                const SizedBox(height: 6),
                const Text(
                  'Novedad:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Reducido para mejor ajuste
                  ),
                ),
                Text(
                  shiftReports.first.notes != null && shiftReports.first.notes!.isNotEmpty
                      ? shiftReports.first.notes!
                      : 'SN',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: shiftReports.first.notes == null || shiftReports.first.notes!.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: shiftReports.first.notes == null || shiftReports.first.notes!.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nuevo widget optimizado para mostrar datos de producción
  Widget _buildProductionDataList(Report report) {
    final items = <Widget>[];
    
    report.data.forEach((key, value) {
      // Formatear la clave (eliminar guiones bajos, capitalizar)
      final formattedKey = key.split('_')
          .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
          .join(' ');
      
      // Formato compacto para valores
      final formattedValue = value is double ? value.toString() : value.toString();
      
      items.add(
        Container(
          margin: const EdgeInsets.only(bottom: 2),
          child: Text(
            '$formattedKey: $formattedValue',
            style: const TextStyle(fontSize: 12), // Tamaño reducido para evitar desbordamiento
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      );
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  // Método para compartir imágenes
  Future<void> _shareDashboardImage(Uint8List pngBytes, String type) async {
    try {
      // Guardar temporalmente la imagen
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/dashboard_${DateFormat('yyyyMMdd').format(_selectedDate)}_$type.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      
      // Compartir la imagen
      await Share.shareXFiles([XFile(filePath)], 
        text: 'Resumen de producción: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}');
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Seleccionar fecha',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _reports.isEmpty ? null : () => _showExportDialog(context),
            tooltip: 'Exportar dashboard',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dashboard principal visible
          if (!_preparingExport)
            ResponsiveLayout(
              mobileLayout: _buildLayout(),
              tabletLayout: _buildLayout(),
            ),
          
          // Indicador de carga durante la exportación
          if (_preparingExport)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // Widget para mostrar el indicador de carga
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Preparando reporte consolidado...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_reports.isEmpty) {
      return _buildEmptyState();
    }
    
    // Si hay plantas con reportes, mostrar la actual
    if (_reportsByPlant.isNotEmpty) {
      final plantName = _reportsByPlant.keys.elementAt(_currentPlantIndex);
      final plantReports = _reportsByPlant[plantName]!;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlantNavigation(plantName),
          const SizedBox(height: 16),
          _buildDetailedDashboard(plantName, plantReports),
        ],
      );
    } else {
      return _buildEmptyState();
    }
  }
  
  // Widget para estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reportes para el día ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear un reporte'),
              onPressed: () => Navigator.pushNamed(context, '/plant_selection')
                  .then((_) => _loadDashboardData()),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget para navegación entre plantas
  Widget _buildPlantNavigation(String plantName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _previousPlant,
          tooltip: 'Planta anterior',
        ),
        Expanded(
          child: Text(
            plantName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: _nextPlant,
          tooltip: 'Planta siguiente',
        ),
      ],
    );
  }

  // Widget para mostrar el dashboard detallado de una planta
  Widget _buildDetailedDashboard(String plantName, List<Report> plantReports) {
    // Agrupar reportes por turno
    Map<String, List<Report>> reportsByShift = {};
    for (var shift in _shifts) {
      reportsByShift[shift] = plantReports.where((r) => r.shift == shift).toList();
    }
    
    return RepaintBoundary(
      key: _singleDashboardKey,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plantName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const Text(
                'Resumen de producción por turno:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Recorremos cada turno
              for (var shift in _shifts) ...[
                if (reportsByShift[shift]!.isNotEmpty) ...[
                  _buildShiftSection(shift, reportsByShift[shift]!),
                  const SizedBox(height: 16),
                ],
              ],
              
              const Text(
                'Novedades reportadas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildNotesList(plantReports),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget para mostrar información de un turno
  Widget _buildShiftSection(String shift, List<Report> reports) {
    // Color para cada turno
    final shiftColors = {
      'Mañana': Colors.amber[700],
      'Tarde': Colors.blue[700],
      'Noche': Colors.indigo[700],
    };
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: shiftColors[shift]?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: shiftColors[shift] ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: shiftColors[shift] ?? Colors.grey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'Turno: $shift',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Líder: ${reports.isNotEmpty ? reports.first.leader : "No asignado"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Datos de producción:'),
                const SizedBox(height: 4),
                
                // Extraer datos de producción del primer reporte del turno
                if (reports.isNotEmpty)
                  _buildProductionData(reports.first)
                else
                  const Text('No hay datos de producción para este turno'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para mostrar datos de producción en formato tabla
  Widget _buildProductionData(Report report) {
    // Extraer datos de producción del reporte
    final productionData = <Widget>[];
    
    report.data.forEach((key, value) {
      // Formatear el nombre de la clave (eliminar guiones bajos, capitalizar)
      final formattedKey = key.split('_')
          .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
          .join(' ');
      
      // Añadir cada dato con su valor
      productionData.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(formattedKey),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      );
    });
    
    return Column(children: productionData);
  }

  // Widget para mostrar lista de notas
  Widget _buildNotesList(List<Report> reports) {
    // Filtrar reportes que tienen notas
    final reportsWithNotes = reports.where((r) => r.notes != null && r.notes!.isNotEmpty).toList();
    
    if (reportsWithNotes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay novedades reportadas para esta planta'),
      );
    }
    
    return Column(
      children: reportsWithNotes.map((report) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              'Turno: ${report.shift}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(report.notes ?? ''),
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }
}