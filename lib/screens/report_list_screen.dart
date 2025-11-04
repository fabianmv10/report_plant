import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/reports/domain/entities/report.dart';
import '../features/reports/presentation/bloc/reports_bloc.dart';
import '../core/di/injection_container.dart';
import '../core/utils/logger.dart';
import '../services/export_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/custom_card.dart';
import '../theme/theme.dart';
import 'package:intl/intl.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsBloc>(
      create: (context) => sl.reportsBloc..add(const ReportsEvent.loadReports()),
      child: const _ReportListScreenContent(),
    );
  }
}

class _ReportListScreenContent extends StatefulWidget {
  const _ReportListScreenContent();

  @override
  State<_ReportListScreenContent> createState() => _ReportListScreenContentState();
}

class _ReportListScreenContentState extends State<_ReportListScreenContent> {
  String _searchQuery = '';

  // Filtros
  String _filterShift = 'Todos';
  String _filterPlant = 'Todas';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _shiftOptions = ['Todos', 'Mañana', 'Tarde', 'Noche'];
  List<String> _plantOptions = ['Todas'];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Método para aplicar filtros a los reportes
  List<Report> _getFilteredReports(List<Report> reports) {
    return reports.where((report) {
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

  void _updatePlantOptions(List<Report> reports) {
    final Set<String> uniquePlants = {'Todas'};
    for (var report in reports) {
      uniquePlants.add(report.plant.name);
    }
    setState(() {
      _plantOptions = uniquePlants.toList()..sort();
    });
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

  Future<void> _handleExportToCSV() async {
    try {
      await ExportService.exportReportsToCSV();
      if (mounted) {
        _showSuccessSnackBar('Reportes exportados a CSV exitosamente');
      }
    } catch (e) {
      logger.error('Error exportando a CSV', e);
      if (mounted) {
        _showErrorSnackBar('Error al exportar a CSV: $e');
      }
    }
  }

  Future<void> _handleExportToJSON() async {
    try {
      await ExportService.exportReportsToJSON();
      if (mounted) {
        _showSuccessSnackBar('Reportes exportados a JSON exitosamente');
      }
    } catch (e) {
      logger.error('Error exportando a JSON', e);
      if (mounted) {
        _showErrorSnackBar('Error al exportar a JSON: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (mounted) {
            // ignore: use_build_context_synchronously
            context.read<ReportsBloc>().add(const ReportsEvent.refreshReports());
          }
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
                color: context.primaryColor.withValues(alpha: 0.2),
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
                          _handleExportToCSV();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('Exportar como JSON'),
                        onTap: () {
                          Navigator.pop(context);
                          _handleExportToJSON();
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
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) => _showErrorSnackBar(message),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (reports, hasReachedMax, filteredByPlant) {
              _updatePlantOptions(reports);
              final filteredReports = _getFilteredReports(reports);
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ReportsBloc>().add(const ReportsEvent.refreshReports());
                },
                child: ResponsiveLayout(
                  mobileLayout: _buildMobileLayout(filteredReports),
                  tabletLayout: _buildTabletLayout(filteredReports),
                ),
              );
            },
            error: (message) => _buildErrorState(context, message),
            syncing: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sincronizando reportes...'),
                ],
              ),
            ),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar reportes',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            onPressed: () {
              context.read<ReportsBloc>().add(const ReportsEvent.refreshReports());
            },
          ),
        ],
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
              backgroundColor: AppTheme.shiftColors[_filterShift]?.withValues(alpha: 0.2),
            ),

          if (_filterPlant != 'Todas')
            Chip(
              label: Text('Planta: $_filterPlant'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _filterPlant = 'Todas'),
              backgroundColor: context.primaryColor.withValues(alpha: 0.2),
            ),

          if (_startDate != null && _endDate != null)
            Chip(
              label: Text('${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() {
                _startDate = null;
                _endDate = null;
              }),
              backgroundColor: context.primaryColor.withValues(alpha: 0.2),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => _buildFilterSheetContent(context, setState),
        );
      },
    );
  }

  // ignore: avoid-unused-parameters
  Widget _buildFilterSheetContent(BuildContext context, StateSetter sheetSetState) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            _buildFilterSheetHeader(context),
            const SizedBox(height: 24),
            _buildShiftFilterSection(sheetSetState),
            const SizedBox(height: 16),
            _buildPlantFilterSection(sheetSetState),
            const SizedBox(height: 16),
            _buildDateRangeFilterSection(context, sheetSetState),
            const SizedBox(height: 24),
            _buildFilterActionButtons(context, sheetSetState),
          ],
        );
      },
    );
  }

  Widget _buildFilterSheetHeader(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildShiftFilterSection(StateSetter sheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turno',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildShiftDropdown(sheetSetState),
      ],
    );
  }

  Widget _buildShiftDropdown(StateSetter sheetSetState) {
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
          sheetSetState(() {
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

  Widget _buildPlantFilterSection(StateSetter sheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planta',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildPlantDropdown(sheetSetState),
      ],
    );
  }

  Widget _buildPlantDropdown(StateSetter sheetSetState) {
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
          sheetSetState(() {
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

  Widget _buildDateRangeFilterSection(BuildContext context, StateSetter sheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Fechas',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildDateRangePicker(context, sheetSetState),
      ],
    );
  }

  Widget _buildDateRangePicker(BuildContext context, StateSetter sheetSetState) {
    final String dateRangeText = _startDate != null && _endDate != null
        ? '${_dateFormat.format(_startDate!)} - ${_dateFormat.format(_endDate!)}'
        : 'Seleccionar fechas';

    return InkWell(
      onTap: () => _selectDateRangeFromSheet(context, sheetSetState),
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
                onPressed: () {
                  sheetSetState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRangeFromSheet(BuildContext context, StateSetter sheetSetState) async {
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
      sheetSetState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
      });
    }
  }

  Widget _buildFilterActionButtons(BuildContext context, StateSetter sheetSetState) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aplicar Filtros'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            sheetSetState(() {
              _filterShift = 'Todos';
              _filterPlant = 'Todas';
              _startDate = null;
              _endDate = null;
            });
            setState(() {
              _resetFilters();
            });
          },
          child: const Text('Limpiar Filtros'),
        ),
      ],
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
                .then((_) {
                  if (context.mounted) {
                    // ignore: use_build_context_synchronously
                    context.read<ReportsBloc>().add(const ReportsEvent.refreshReports());
                  }
                }),
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
              color: context.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
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
                color: context.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportDetails(Report report) {
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
                            report.plant.name,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(report.leader),
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
                          color: Colors.grey.withValues(alpha: 0.1),
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
