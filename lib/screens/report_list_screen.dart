import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../services/export_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/custom_card.dart';
import '../theme/theme.dart';
import 'package:intl/intl.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<Report> _reports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  // Filtros
  String _filterShift = 'Todos';
  String _filterPlant = 'Todas';
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<String> _shiftOptions = ['Todos', 'Mañana', 'Tarde', 'Noche'];
  List<String> _plantOptions = ['Todas'];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Cargar los reportes cuando se inicia la pantalla
    _loadReports();
  }

  // Método para cargar los reportes desde la base de datos
  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Cargar todos los reportes
      final allReports = await DatabaseHelper.instance.getAllReports();
      
      // Extraer plantas únicas para los filtros
      final Set<String> uniquePlants = {'Todas'};
      for (var report in allReports) {
        uniquePlants.add(report.plant.name);
      }
      _plantOptions = uniquePlants.toList()..sort();
      
      setState(() {
        _reports = allReports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al cargar reportes: $e');
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

  // Método para aplicar filtros a los reportes
  List<Report> _getFilteredReports() {
    return _reports.where((report) {
      // Filtrar por turno
      if (_filterShift != 'Todos' && report.shift != _filterShift) {
        return false;
      }
      
      // Filtrar por planta
      if (_filterPlant != 'Todas' && report.plant.name != _filterPlant) {
        return false;
      }
      
      // Filtrar por fecha inicial
      if (_startDate != null) {
        final reportDate = DateTime(
          report.timestamp.year,
          report.timestamp.month,
          report.timestamp.day,
        );
        
        final startDateOnly = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        
        if (reportDate.isBefore(startDateOnly)) {
          return false;
        }
      }
      
      // Filtrar por fecha final
      if (_endDate != null) {
        final reportDate = DateTime(
          report.timestamp.year,
          report.timestamp.month,
          report.timestamp.day,
        );
        
        final endDateOnly = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );
        
        if (reportDate.isAfter(endDateOnly)) {
          return false;
        }
      }
      
      // Filtrar por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return report.leader.toLowerCase().contains(query) ||
              report.plant.name.toLowerCase().contains(query) ||
              (report.notes != null && report.notes!.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );
    
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
    
    if (newDateRange != null) {
      setState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
      });
    }
  }
  
  void _resetFilters() {
    setState(() {
      _filterShift = 'Todos';
      _filterPlant = 'Todas';
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _getFilteredReports();
    final hasActiveFilters = _filterShift != 'Todos' || 
                          _filterPlant != 'Todas' || 
                          _startDate != null || 
                          _endDate != null ||
                          _searchQuery.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a la selección de planta y luego regresar para refrescar
          await Navigator.pushNamed(context, '/plant_selection');
          _loadReports(); // Refrescar la lista después de regresar
        },
        tooltip: 'Crear nuevo reporte',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Reportes de Turno'),
        actions: [
          // Icono indicador de filtro activo
          if (hasActiveFilters)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list_alt),
                tooltip: 'Limpiar filtros',
                onPressed: _resetFilters,
              ),
            ),
          
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar reportes',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobileLayout: _buildMobileLayout(filteredReports),
              tabletLayout: _buildTabletLayout(filteredReports),
            ),
    );
  }
   
  Widget _buildMobileLayout(List<Report> reports) {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar reportes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtros',
                onPressed: () => _showFilterSheet(context),
              ),
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
        
        // Chips de filtros activos
        if (_startDate != null || _endDate != null || _filterShift != 'Todos' || _filterPlant != 'Todas')
          _buildActiveFilters(),
          
        // Lista de reportes
        Expanded(
          child: reports.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: reports.length,
                  padding: const EdgeInsets.all(8),
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
          width: 280,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Filtros',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar reportes...',
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
                const SizedBox(height: 24),
                
                // Filtro por turno
                Text(
                  'Turno',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildShiftFilter(),
                const SizedBox(height: 16),
                
                // Filtro por planta
                Text(
                  'Planta',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildPlantFilter(),
                const SizedBox(height: 16),
                
                // Filtro por rango de fechas
                Text(
                  'Rango de Fechas',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildDateRangeFilter(context),
                const SizedBox(height: 24),
                
                // Botón para limpiar filtros
                if (_startDate != null || _endDate != null || _filterShift != 'Todos' || _filterPlant != 'Todas' || _searchQuery.isNotEmpty)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpiar Filtros'),
                    onPressed: _resetFilters,
                  ),
              ],
            ),
          ),
        ),
        
        // Lista de reportes
        Expanded(
          child: reports.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
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

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_filterShift != 'Todos')
            Chip(
              label: Text('Turno: $_filterShift'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _filterShift = 'Todos'),
              backgroundColor: AppTheme.shiftColors[_filterShift]?.withOpacity(0.2),
            ),
            
          if (_filterPlant != 'Todas')
            Chip(
              label: Text('Planta: $_filterPlant'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _filterPlant = 'Todas'),
              backgroundColor: context.primaryColor.withOpacity(0.2),
            ),
            
          if (_startDate != null && _endDate != null)
            Chip(
              label: Text('${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() {
                _startDate = null;
                _endDate = null;
              }),
              backgroundColor: context.primaryColor.withOpacity(0.2),
            ),
        ],
      ),
    );
  }

  Widget _buildShiftFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _filterShift,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        underline: Container(),
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
      ),
    );
  }
  
  Widget _buildPlantFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _filterPlant,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        underline: Container(),
        onChanged: (String? newValue) {
          setState(() {
            _filterPlant = newValue!;
          });
        },
        items: _plantOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildDateRangeFilter(BuildContext context) {
    final String dateRangeText = _startDate != null && _endDate != null
        ? '${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)}'
        : 'Seleccionar fechas';
        
    return InkWell(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 8),
            Expanded(
              child: Text(dateRangeText),
            ),
            if (_startDate != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() {
                  _startDate = null;
                  _endDate = null;
                }),
              ),
          ],
        ),
      ),
    );
  }
  
  // Bottom sheet para filtros en vista móvil
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros',
                        style: context.textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Turno',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _filterShift,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      underline: Container(),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Planta',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _filterPlant,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterPlant = newValue!;
                        });
                      },
                      items: _plantOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Rango de Fechas',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final initialDateRange = DateTimeRange(
                        start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                        end: _endDate ?? DateTime.now(),
                      );
                      
                      final newDateRange = await showDateRangePicker(
                        context: context,
                        initialDateRange: initialDateRange,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      
                      if (newDateRange != null) {
                        setState(() {
                          _startDate = newDateRange.start;
                          _endDate = newDateRange.end;
                        });
                        // Actualizar también el estado del widget padre
                        this.setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)}'
                                  : 'Seleccionar fechas',
                            ),
                          ),
                          if (_startDate != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                                // Actualizar también el estado del widget padre
                                this.setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Ya se han actualizado los estados en los controles
                    },
                    child: const Text('Aplicar Filtros'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterShift = 'Todos';
                        _filterPlant = 'Todas';
                        _startDate = null;
                        _endDate = null;
                      });
                      // Actualizar también el estado del widget padre
                      this.setState(() {
                        _resetFilters();
                      });
                    },
                    child: const Text('Limpiar Filtros'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: AppTheme.textHintColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty && _filterShift == 'Todos' && _filterPlant == 'Todas' && _startDate == null
                ? 'No hay reportes disponibles'
                : 'No se encontraron reportes con los filtros aplicados',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Crear nuevo reporte'),
            onPressed: () => Navigator.pushNamed(context, '/plant_selection')
                .then((_) => _loadReports()),
          ),
        ],
      ),
    );
  }

  Widget _buildReportListItem(Report report) {
    // ignore: unused_local_variable
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    // ignore: unused_local_variable
    final shiftColor = AppTheme.shiftColors[report.shift] ?? Colors.grey[700]!;
    
    return ReportCard(
      title: report.plant.name,
      shift: report.shift,
      leader: report.leader,
      timestamp: report.timestamp,
      onTap: () => _showReportDetails(report),
      content: report.notes != null && report.notes!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Text(
                'Novedad: ${report.notes}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: context.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ],
          )
        : null,
    );
  }

  Widget _buildReportGridItem(Report report) {
    // ignore: unused_local_variable
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    // ignore: unused_local_variable
    final shiftColor = AppTheme.shiftColors[report.shift] ?? Colors.grey[700]!;
    
    return ReportCard(
      title: report.plant.name,
      shift: report.shift,
      leader: report.leader,
      timestamp: report.timestamp,
      onTap: () => _showReportDetails(report),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            'Datos registrados:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${report.data.length} parámetros',
            style: TextStyle(
              fontSize: 12,
              color: context.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Novedad: ${report.notes}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: context.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportDetails(Report report) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final shiftColor = AppTheme.shiftColors[report.shift] ?? Colors.grey[700]!;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: shiftColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getShiftIcon(report.shift),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reporte del ${formatter.format(report.timestamp)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.factory),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Planta: ${report.plant.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text('Líder: ${report.leader}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Parámetros:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    
                    // Parámetros en formato de tabla
                    DataTable(
                      columnSpacing: 16,
                      horizontalMargin: 0,
                      headingRowHeight: 40,
                      dataRowMinHeight: 40,
                      border: TableBorder.all(
                        color: context.theme.dividerColor,
                        width: 1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Parámetro',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Valor',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: report.data.entries.map((entry) => DataRow(
                        cells: [
                          DataCell(Text(_formatKey(entry.key))),
                          DataCell(Text(entry.value.toString())),
                        ],
                      )).toList(),
                    ),
                    
                    if (report.notes != null && report.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Novedades:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.theme.dividerColor),
                        ),
                        child: Text(report.notes!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formatea las claves del mapa para mostrarlas
  String _formatKey(String key) {
    return key.split('_').map((word) => word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1)}' 
        : '').join(' ');
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