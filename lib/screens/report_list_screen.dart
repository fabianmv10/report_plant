import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../widgets/responsive_layout.dart';
import 'package:intl/intl.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  // Datos de ejemplo (después serán reemplazados por datos reales)
  List<Report> _reports = [];
  String _filterShift = 'Todos';
  final List<String> _shiftOptions = ['Todos', 'Mañana', 'Tarde', 'Noche'];

  @override
  Widget build(BuildContext context) {

    // En el método build o initState de ReportListScreen
    Future<void> _loadReports() async {
      final reports = await DatabaseHelper.instance.getAllReports();
      setState(() {
        _reports = reports;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Turno'),
      ),
      body: ResponsiveLayout(
        mobileLayout: _buildMobileLayout(),
        tabletLayout: _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _reports.isEmpty
              ? const Center(child: Text('No hay reportes disponibles'))
              : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportListItem(_reports[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Panel lateral con filtros
        SizedBox(
          width: 250,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Turno'),
                  const SizedBox(height: 8),
                  _buildShiftDropdown(),
                ],
              ),
            ),
          ),
        ),
        // Lista de reportes
        Expanded(
          child: _reports.isEmpty
              ? const Center(child: Text('No hay reportes disponibles'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportGridItem(_reports[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Filtrar por:'),
          const SizedBox(width: 8),
          Expanded(child: _buildShiftDropdown()),
        ],
      ),
    );
  }

  Widget _buildShiftDropdown() {
    return DropdownButton<String>(
      isExpanded: true,
      value: _filterShift,
      onChanged: (String? newValue) {
        setState(() {
          _filterShift = newValue!;
        });
      },
      items: _shiftOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildReportListItem(Report report) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text('Operador: ${report.operator}'),
        subtitle: Text(
            'Turno: ${report.shift} - Fecha: ${formatter.format(report.timestamp)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  Widget _buildReportGridItem(Report report) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _showReportDetails(report),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatter.format(report.timestamp),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Operador: ${report.operator}'),
              Text('Turno: ${report.shift}'),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Ver detalles'),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(Report report) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reporte del ${formatter.format(report.timestamp)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Operador: ${report.operator}'),
              Text('Turno: ${report.shift}'),
              const Divider(),
              const Text('Parámetros:'),
              ...report.data.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('${_formatKey(entry.key)}: ${entry.value}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Formatea las claves del mapa para mostrarlas
  String _formatKey(String key) {
    return key.split('_').map((word) => word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1)}' 
        : '').join(' ');
  }
}