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
import '../widgets/custom_card.dart';
import '../theme/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _singleDashboardKey = GlobalKey();
  bool _isLoading = false;
  bool _preparingExport = false;
  DateTime _selectedDate = DateTime.now();
  List<Report> _reports = [];
  Map<String, List<Report>> _reportsByPlant = {};
  final List<String> _shifts = ['Mañana', 'Tarde', 'Noche'];
  
  // Para navegación entre plantas
  int _currentPlantIndex = 0;
  
  // Para las animaciones de pestaña
  late TabController _tabController;
  final List<String> _tabTitles = ['Producción', 'Turnos', 'Novedades'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: context.theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: context.theme.cardColor,
              onSurface: context.textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
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
      _tabController.animateTo(0); // Resetear a la primera pestaña al cambiar de planta
    }
  }

  void _previousPlant() {
    if (_reportsByPlant.isNotEmpty) {
      setState(() {
        _currentPlantIndex = (_currentPlantIndex - 1 + _reportsByPlant.length) % _reportsByPlant.length;
      });
      _tabController.animateTo(0); // Resetear a la primera pestaña al cambiar de planta
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
    const double totalWidth = plantWidth * fixedColumns + 48; // Incluir padding
    
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
                      return const SizedBox(width: plantWidth);
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
        color: AppTheme.primaryColor,
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
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
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
    // Usar colores del tema para los turnos
    final shiftColor = AppTheme.shiftColors[shift] ?? Colors.grey[700]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: shiftColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del turno
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: shiftColor.withOpacity(0.2),
            child: Text(
              'Turno: $shift',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: shiftColor,
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
        elevation: 2,
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
          
          // Añadir resumen estadístico
          _buildStatisticsSummary(plantReports),
          const SizedBox(height: 16),
          
          // Contenido en pestañas
          _buildTabContent(plantName, plantReports),
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
              color: AppTheme.textHintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reportes para el día ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.primaryColor,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              plantName,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
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
  
  // Widget para mostrar estadísticas de resumen
  Widget _buildStatisticsSummary(List<Report> reports) {
    // Calcular algunas estadísticas útiles
    final totalReports = reports.length;
    final uniqueLeaders = reports.map((r) => r.leader).toSet().length;
    final hasMorningShift = reports.any((r) => r.shift == 'Mañana');
    final hasAfternoonShift = reports.any((r) => r.shift == 'Tarde');
    final hasNightShift = reports.any((r) => r.shift == 'Noche');
    final shiftsCompleted = [hasMorningShift, hasAfternoonShift, hasNightShift].where((s) => s).length;
    
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          StatCard(
            title: 'Total Reportes',
            value: '$totalReports',
            subtitle: 'Para esta planta',
            icon: Icons.assignment,
            color: AppTheme.primaryColor,
            trend: Trend.neutral,
          ),
          const SizedBox(width: 12),
          StatCard(
            title: 'Líderes',
            value: '$uniqueLeaders',
            subtitle: 'Reportadores diferentes',
            icon: Icons.person,
            color: AppTheme.secondaryColor,
            trend: Trend.neutral,
          ),
          const SizedBox(width: 12),
          StatCard(
            title: 'Turnos Completados',
            value: '$shiftsCompleted / 3',
            subtitle: shiftsCompleted == 3 ? 'Todos los turnos registrados' : 'Faltan ${3 - shiftsCompleted} turnos',
            icon: Icons.access_time,
            color: shiftsCompleted == 3 ? AppTheme.successColor : AppTheme.warningColor,
            trend: shiftsCompleted == 3 ? Trend.up : Trend.neutral,
          ),
        ],
      ),
    );
  }

  // Widget para mostrar contenido en pestañas
  Widget _buildTabContent(String plantName, List<Report> plantReports) {
    return RepaintBoundary(
      key: _singleDashboardKey,
      child: CustomCard(
        elevation: 4,
        showHeader: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: context.primaryColor,
                unselectedLabelColor: context.textTheme.bodyMedium?.color?.withOpacity(0.7),
                indicatorColor: context.primaryColor,
                indicatorWeight: 3,
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 400, // Altura fija para el contenido
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductionTab(plantReports),
                  _buildShiftsTab(plantReports),
                  _buildNotesTab(plantReports),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Pestaña de producción con visualización de barras nativa
  Widget _buildProductionTab(List<Report> reports) {
    // Agrupar datos por turno para mostrar comparativas
    final shiftsData = <String, Map<String, dynamic>>{};
    
    for (var report in reports) {
      final shift = report.shift;
      if (!shiftsData.containsKey(shift)) {
        shiftsData[shift] = {};
      }
      
      report.data.forEach((key, value) {
        if (value is num || value is String && double.tryParse(value) != null) {
          // Intentar obtener valor numérico
          final numValue = value is num ? value.toDouble() : double.tryParse(value) ?? 0.0;
          shiftsData[shift]![key] = numValue;
        }
      });
    }
    
    // Si no hay datos para mostrar
    if (shiftsData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No hay datos de producción disponibles'),
        ),
      );
    }
    
    // Determinar métricas comunes entre turnos para poder comparar
    final Set<String> commonMetrics = {};
    bool isFirstShift = true;
    
    for (var shiftData in shiftsData.values) {
      if (isFirstShift) {
        commonMetrics.addAll(shiftData.keys);
        isFirstShift = false;
      } else {
        commonMetrics.retainAll(shiftData.keys);
      }
    }
    
    // Si no hay métricas comunes
    if (commonMetrics.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No hay métricas comunes para comparar entre turnos'),
        ),
      );
    }
    
    // Seleccionar algunas métricas clave para mostrar en gráficos
    List<String> metricsToShow = commonMetrics.take(3).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparativa de producción por turno',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Gráfico de barras nativo para comparar métricas entre turnos
          SizedBox(
            height: 200,
            child: _buildNativeBarChart(shiftsData, metricsToShow),
          ),
          
          const SizedBox(height: 24),
          Text(
            'Detalle de métricas por turno',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Tabla detallada de datos
          _buildDataTable(shiftsData, commonMetrics),
        ],
      ),
    );
  }
  
  // Widget para construir un gráfico de barras nativo sin dependencias
  Widget _buildNativeBarChart(Map<String, Map<String, dynamic>> shiftsData, List<String> metrics) {
    final List<String> shifts = shiftsData.keys.toList();
    final Map<String, Color> shiftColorMap = {
      for (var shift in shifts) 
        shift: AppTheme.shiftColors[shift] ?? AppTheme.primaryColor,
    };
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Column(
        children: [
          // Leyenda del gráfico
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: shifts.map((shift) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: shiftColorMap[shift],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(shift, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Área del gráfico
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: metrics.map((metric) {
                // Formatear nombre de métrica para mostrar
                final formattedMetric = metric.split('_')
                  .map((word) => word.isNotEmpty 
                    ? '${word[0].toUpperCase()}${word.substring(1)}' 
                    : '')
                  .join(' ');
                  
                // Calcular el valor máximo para esta métrica entre todos los turnos
                double maxValue = 0;
                for (var shift in shifts) {
                  final value = shiftsData[shift]![metric] as double? ?? 0.0;
                  if (value > maxValue) maxValue = value;
                }
                
                // Ajustar a un valor más amigable para mostrar
                maxValue = maxValue * 1.2; // 20% de margen
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Barras para cada turno
                        ...shifts.map((shift) {
                          final value = shiftsData[shift]![metric] as double? ?? 0.0;
                          final double heightPercentage = maxValue > 0 ? value / maxValue : 0;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            width: 20,
                            height: 100 * heightPercentage,
                            decoration: BoxDecoration(
                              color: shiftColorMap[shift],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: value > 0 && heightPercentage > 0.2
                                ? Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          );
                        }),
                        
                        // Nombre de la métrica
                        const SizedBox(height: 8),
                        Text(
                          formattedMetric,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para construir tabla de datos detallados
  Widget _buildDataTable(Map<String, Map<String, dynamic>> shiftsData, Set<String> metrics) {
    final List<String> shifts = shiftsData.keys.toList();
    
    // Ordenar métricas alfabéticamente para mejor presentación
    final List<String> sortedMetrics = metrics.toList()..sort();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStateProperty.all(context.primaryColor.withOpacity(0.1)),
        border: TableBorder.all(
          color: context.theme.dividerColor,
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: [
          const DataColumn(
            label: Expanded(
              child: Text(
                'Métrica',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ...shifts.map((shift) => DataColumn(
            label: Expanded(
              child: Text(
                shift,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.shiftColors[shift] ?? AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )),
        ],
        rows: sortedMetrics.map((metric) {
          // Formatear nombre de métrica para mostrar
          final formattedMetric = metric.split('_')
            .map((word) => word.isNotEmpty 
              ? '${word[0].toUpperCase()}${word.substring(1)}' 
              : '')
            .join(' ');
            
          return DataRow(
            cells: [
              DataCell(Text(formattedMetric)),
              ...shifts.map((shift) {
                final value = shiftsData[shift]![metric];
                return DataCell(
                  Text(
                    value?.toString() ?? '-',
                    textAlign: TextAlign.right,
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  // Pestaña de turnos
  Widget _buildShiftsTab(List<Report> reports) {
    // Agrupar reportes por turno
    Map<String, List<Report>> reportsByShift = {};
    for (var shift in _shifts) {
      reportsByShift[shift] = reports.where((r) => r.shift == shift).toList();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var shift in _shifts) ...[
            if (reportsByShift[shift]!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildShiftSection(shift, reportsByShift[shift]!),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }
  
  // Widget para mostrar información de un turno
  Widget _buildShiftSection(String shift, List<Report> reports) {
    // Usar colores del tema para cada turno
    final shiftColor = AppTheme.shiftColors[shift] ?? Colors.grey[700]!;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: shiftColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: shiftColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: shiftColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getShiftIcon(shift),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Turno: $shift',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Líder: ${reports.isNotEmpty ? reports.first.leader : "No asignado"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos de producción:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                // Datos de producción formateados en grid
                if (reports.isNotEmpty)
                  _buildProductionGrid(reports.first)
                else
                  const Text('No hay datos de producción para este turno'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para mostrar datos de producción en formato grid
  Widget _buildProductionGrid(Report report) {
    final List<MapEntry<String, dynamic>> data = report.data.entries.toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 8,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data[index];
        final formattedKey = entry.key.split('_')
          .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
          .join(' ');
          
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  formattedKey,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Pestaña de notas y novedades
  Widget _buildNotesTab(List<Report> reports) {
    // Filtrar reportes que tienen notas
    final reportsWithNotes = reports.where((r) => r.notes != null && r.notes!.isNotEmpty).toList();
    
    if (reportsWithNotes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No hay novedades reportadas para esta planta'),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reportsWithNotes.length,
      itemBuilder: (context, index) {
        final report = reportsWithNotes[index];
        final shiftColor = AppTheme.shiftColors[report.shift] ?? Colors.grey[700]!;
        
        return CustomCard(
          title: 'Novedad - Turno ${report.shift}',
          subtitle: 'Reportado por ${report.leader}',
          accentColor: shiftColor,
          icon: Icons.notifications,
          contentPadding: const EdgeInsets.all(16),
          child: Text(report.notes ?? ''),
        );
      },
    );
  }
  
  // Obtener icono para cada turno
  IconData _getShiftIcon(String shift) {
    switch (shift) {
      case 'Mañana':
        return Icons.wb_sunny;
      case 'Tarde':
        return Icons.wb_twilight;
      case 'Noche':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }
}