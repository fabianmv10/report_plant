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
  final GlobalKey _consolidatedDashboardKey = GlobalKey();
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
      print('Error cargando datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _captureSingleDashboard() async {
    try {
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary = 
          _singleDashboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        _shareDashboardImage(pngBytes, 'single');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  Future<void> _captureConsolidatedDashboard() async {
    try {
      // Primero aseguramos que se construya el widget consolidado
      setState(() {
        _preparingExport = true;
      });
      
      // Dar tiempo para que el widget se renderice completamente
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Ahora intentamos capturar la imagen
      final RenderRepaintBoundary? boundary = 
          _consolidatedDashboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se pudo generar la imagen. Intente nuevamente.')),
        );
        setState(() {
          _preparingExport = false;
        });
        return;
      }
      
      // Capturar la imagen con una escala adecuada para un buen resultado
      // Usamos un valor más alto para asegurar que la imagen tenga buena calidad al ser más ancha
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('No se pudo obtener los datos de la imagen');
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      await _shareDashboardImage(pngBytes, 'consolidated');
      
      // Restaurar el estado
      setState(() {
        _preparingExport = false;
      });
    } catch (e) {
      print('Error en captura: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
      setState(() {
        _preparingExport = false;
      });
    }
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir: $e')),
      );
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
          
          // Dashboard consolidado para captura
          if (_preparingExport)
            // Al exportar, mostramos un indicador de carga encima del contenido
            Stack(
              children: [
                // Widget de exportación visible temporalmente
                SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _consolidatedDashboardKey,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: _buildConsolidatedContent(),
                    ),
                  ),
                ),
                // Indicador semi-transparente encima
                Container(
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
                ),
              ],
            )
          else
            // Este container escondido mantiene el widget en el árbol
            // pero no visible, lo cual es necesario para mantener su contexto
            Container(
              width: 0,
              height: 0,
              child: RepaintBoundary(
                key: _consolidatedDashboardKey,
                child: Container(
                  color: Colors.white,
                  child: _buildConsolidatedContent(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Método separado para construir el contenido consolidado
  Widget _buildConsolidatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Container(
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
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Disponer las plantas en filas de dos columnas
        for (int i = 0; i < _reportsByPlant.length; i += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera planta en la fila
              Expanded(
                child: _buildPlantColumn(_reportsByPlant.entries.elementAt(i)),
              ),
              const SizedBox(width: 8),
              
              // Segunda planta en la fila (si existe)
              if (i + 1 < _reportsByPlant.length)
                Expanded(
                  child: _buildPlantColumn(_reportsByPlant.entries.elementAt(i + 1)),
                )
              else
                Expanded(child: Container()), // Espacio vacío si no hay otra planta
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // Método para construir una columna de planta individual
  Widget _buildPlantColumn(MapEntry<String, List<Report>> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera de la planta
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            entry.key,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        
        // Datos por turnos
        ..._shifts.map((shift) {
          final reports = entry.value.where((r) => r.shift == shift).toList();
          if (reports.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShiftSectionForExport(shift, reports),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
        
        // Novedades
        _buildNotesListForExport(entry.value),
      ],
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
          ],
        ),
      ),
    );
  }
  
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
            title: Row(
              children: [
                Text(
                  'Turno: ${report.shift}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat('HH:mm').format(report.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
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

  // Versión más compacta para la exportación
  Widget _buildShiftSectionForExport(String shift, List<Report> reports) {
    final shiftColors = {
      'Mañana': Colors.amber[700],
      'Tarde': Colors.blue[700],
      'Noche': Colors.indigo[700],
    };
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: shiftColors[shift] ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: shiftColors[shift]?.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turno: $shift',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: shiftColors[shift]?.withOpacity(1.0),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Líder: ${reports.isNotEmpty ? reports.first.leader : "No asignado"}',
                  style: TextStyle(
                    color: shiftColors[shift]?.withOpacity(1.0),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: reports.isNotEmpty
                ? _buildCompactProductionData(reports.first)
                : const Text('No hay datos', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Versión más compacta para mostrar los datos de producción en columnas
  Widget _buildCompactProductionData(Report report) {
    // Extraer datos de producción del reporte
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: report.data.entries.map((entry) {
        // Formatear el nombre de la clave
        final formattedKey = entry.key.split('_')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$formattedKey: ${entry.value}',
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
    );
  }

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
                child: Text(formattedKey),
              ),
              Text(
                value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    });
    
    return Column(children: productionData);
  }

  Widget _buildNotesListForExport(List<Report> reports) {
    // Filtrar reportes que tienen notas
    final reportsWithNotes = reports.where((r) => r.notes != null && r.notes!.isNotEmpty).toList();
    
    if (reportsWithNotes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          color: Colors.grey[300],
          child: const Text(
            'Novedades:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...reportsWithNotes.map((report) {
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      report.shift,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(report.timestamp),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  report.notes ?? '',
                  style: const TextStyle(fontSize: 10),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}