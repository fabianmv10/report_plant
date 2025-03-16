import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../services/export_service.dart';
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
  void initState() {
    super.initState();
    // Cargar los reportes cuando se inicia la pantalla
    _loadReports();
  }

  // Método para cargar los reportes desde la base de datos
  Future<void> _loadReports() async {
    try {
      final reports = await DatabaseHelper.instance.getAllReports();
      setState(() {
        _reports = reports;
      });
      print("Reportes cargados: ${reports.length}");
    } catch (e) {
      print("Error al cargar reportes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    // En el método build o initState de ReportListScreen
    Future<void> loadReports() async {
      final reports = await DatabaseHelper.instance.getAllReports();
      setState(() {
        _reports = reports;
      });
    }

    // Filtrar reportes según el turno seleccionado
    List<Report> filteredReports = _filterShift == 'Todos'
        ? _reports
        : _reports.where((report) => report.shift == _filterShift).toList();

    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a la selección de planta y luego regresar para refrescar
          await Navigator.pushNamed(context, '/plant_selection');
          _loadReports(); // Refrescar la lista después de regresar
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Reportes de Turno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exportar Datos'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.table_chart),
                        title: const Text('Exportar como CSV'),
                        onTap: () {
                          Navigator.pop(context);
                          ExportService.exportReportsToCSV();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('Exportar como JSON'),
                        onTap: () {
                          Navigator.pop(context);
                          ExportService.exportReportsToJSON();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileLayout: _buildMobileLayout(filteredReports),
        tabletLayout: _buildTabletLayout(filteredReports),
      ),
    );
  }
   

  Widget _buildMobileLayout(List<Report> reports) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _reports.isEmpty
              ? const Center(child: Text('No hay reportes disponibles'))
              : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportListItem(reports[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(List<Report> reports) {
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
          child: reports.isEmpty
              ? const Center(child: Text('No hay reportes disponibles'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportGridItem(reports[index]);
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
        title: Text('Operador: ${report.leader}'),
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
              Text('Operador: ${report.leader}'),
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
              Text('Operador: ${report.leader}'),
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