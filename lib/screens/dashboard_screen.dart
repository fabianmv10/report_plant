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
  final GlobalKey _dashboardKey = GlobalKey();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<Report> _reports = [];
  Map<String, int> _reportsByPlant = {};
  Map<String, int> _reportsByShift = {};

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
      
      // Reportes por planta
      _reportsByPlant = {};
      for (var report in _reports) {
        _reportsByPlant[report.plant.name] = 
            (_reportsByPlant[report.plant.name] ?? 0) + 1;
      }
      
      // Reportes por turno
      _reportsByShift = {};
      for (var report in _reports) {
        _reportsByShift[report.shift] = 
            (_reportsByShift[report.shift] ?? 0) + 1;
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

  Future<void> _captureAndShareDashboard() async {
    try {
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary = 
          _dashboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Guardar temporalmente la imagen
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/dashboard_${DateFormat('yyyyMMdd').format(_selectedDate)}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        
        // Compartir la imagen
        await Share.shareXFiles([XFile(filePath)], 
          text: 'Resumen de reportes: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Seleccionar fecha',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _reports.isEmpty ? null : _captureAndShareDashboard,
            tooltip: 'Compartir resumen',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileLayout: _buildMobileLayout(),
        tabletLayout: _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildDashboardContent(),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildDashboardContent(),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: const Text('Cambiar'),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_reports.isEmpty)
          Center(
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
          )
        else
          RepaintBoundary(
            key: _dashboardKey,
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
                      'Resumen del día ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    
                    // Total de reportes
                    _buildInfoCard(
                      'Total de reportes',
                      _reports.length.toString(),
                      Icons.assessment,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    
                    // Reportes por turno
                    const Text(
                      'Reportes por turno:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBarChart(_reportsByShift, Colors.green),
                    const SizedBox(height: 16),
                    
                    // Reportes por planta
                    const Text(
                      'Reportes por planta:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBarChart(_reportsByPlant, Colors.purple),
                    
                    if (_reports.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Últimos reportes:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._reports.take(3).map((report) => _buildReportItem(report)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return const Text('No hay datos disponibles');
    }
    
    // Encontrar el valor máximo para escalar las barras
    final maxValue = data.values.reduce((max, value) => max > value ? max : value);
    
    return Column(
      children: data.entries.map((entry) {
        final percentage = maxValue > 0 ? (entry.value / maxValue) * 100 : 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  entry.value.toString(),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportItem(Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[700],
          child: Text(
            report.plant.name.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(report.plant.name),
        subtitle: Text('Líder: ${report.leader} - Turno: ${report.shift}'),
        trailing: Text(
          DateFormat('HH:mm').format(report.timestamp),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}