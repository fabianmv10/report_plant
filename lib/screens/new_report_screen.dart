import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/custom_card.dart';
import '../theme/theme.dart';

class NewReportScreen extends StatefulWidget {
  final Plant plant;
  
  const NewReportScreen({super.key, required this.plant});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  String _selectedShift = 'Mañana';
  final Map<String, dynamic> _reportData = {};
  bool _isSaving = false;
  
  // Agregar controlador de fecha y fecha seleccionada
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  
  final List<String> _shifts = ['Mañana', 'Tarde', 'Noche'];
  late List<Map<String, dynamic>> _parameters;

  final List<String> _leader = [
    'Andres Caballero',
    'Cesar Lopez',
    'Evelyn Meneses',
    'Faber Moncayo',
    'Lady Martinez',
  ];
  String _selectedLeader = 'Andres Caballero';

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de fecha
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    
    // Parámetros específicos según la planta seleccionada
    _parameters = _getPlantParameters(widget.plant.id);
     // Inicializar los valores por defecto para todos los parámetros
    for (var param in _parameters) {
      final String fieldId = param['name'].toString().toLowerCase().replaceAll(' ', '_');
      if (param['type'] == 'dropdown') {
        // Para dropdowns, usar el primer valor como default
        _reportData[fieldId] = param['options'][0];
      } else if (param.containsKey('min')) {
        // Para campos numéricos, usar el valor mínimo como default
        _reportData[fieldId] = param['min'];
      }
    }
  }

  List<Map<String, dynamic>> _getPlantParameters(String plantId) {
    // La implementación original se mantiene igual
    switch (plantId) {
      case '1': // Sulfato de Aluminio Tipo A
        return [
          {'name': 'Referencia', 'type': 'dropdown', 'options': ['SATA x 25 Kg', 'SATA IF x 25 Kg', 'SATA IF x 1000 Kg']},
          {'name': 'Producción Primera Reacción', 'unit': 'Un', 'min': 0, 'max': 150},
          {'name': 'Producción Segunda Reacción', 'unit': 'Un', 'min': 0, 'max': 150},
          {'name': 'Producción Liquida', 'unit': 'kg', 'min': 0, 'max': 16000},
        ];
      case '2': // Sulfato de Aluminio Tipo B
        return [
          {'name': 'Reacción de STBS', 'unit': 'Cochada', 'min': 0, 'max': 2},
          {'name': 'Reacción de STBL', 'unit': 'Cochada', 'min': 0, 'max': 2},
          {'name': 'Producción STBS Empaque', 'unit': 'Un', 'min': 0, 'max': 300},
          {'name': 'Producción STBL Tanque', 'unit': 'Kg', 'min': 0, 'max': 50000},
        ];
      // Los demás casos se mantienen igual
      // ...
      default:
        return [
          {'name': 'Temperatura', 'unit': '°C', 'min': 30, 'max': 90},
          {'name': 'Presión', 'unit': 'bar', 'min': 1, 'max': 5},
          {'name': 'pH', 'unit': '', 'min': 5, 'max': 9},
          {'name': 'Nivel de tanque', 'unit': '%', 'min': 0, 'max': 100},
        ];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }
  
  // Función para seleccionar fecha
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
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    for (var param in _parameters) {
      if (param['type'] == 'dropdown') {
        final String fieldId = param['name'].toString().toLowerCase().replaceAll(' ', '_');
        if (!_reportData.containsKey(fieldId) || 
            !param['options'].contains(_reportData[fieldId])) {
          // Si el valor actual no es válido, asignar el primer valor por defecto
          _reportData[fieldId] = param['options'][0];
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Reporte - ${widget.plant.name}'),
        actions: [
          // Botón para guardar en la AppBar
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar reporte',
            onPressed: _isSaving ? null : _submitForm,
          ),
        ],
      ),
      body: _isSaving 
        ? _buildSavingIndicator() 
        : ResponsiveLayout(
            mobileLayout: _buildMobileLayout(),
            tabletLayout: _buildTabletLayout(),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving ? null : _submitForm,
        // ignore: sort_child_properties_last
        child: const Icon(Icons.save),
        tooltip: 'Guardar reporte',
      ),
    );
  }
  
  // Indicador de carga durante el guardado
  Widget _buildSavingIndicator() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Guardando reporte...'),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    // Color para la planta seleccionada
    final plantColor = AppTheme.plantColors[widget.plant.id] ?? AppTheme.primaryColor;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con información de la planta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [plantColor, plantColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getPlantIcon(widget.plant.id),
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.plant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPlantDescription(widget.plant.id),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Información del turno
            CustomCard(
              title: 'Información del Turno',
              subtitle: 'Datos generales del reporte',
              icon: Icons.info_outline,
              accentColor: AppTheme.primaryColor,
              contentPadding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo para seleccionar fecha
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true, // No permitir edición manual
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  _buildLeaderField(),
                  const SizedBox(height: 16),
                  _buildShiftDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Datos del proceso
            CustomCard(
              title: 'Datos del Proceso',
              subtitle: 'Parámetros específicos para esta planta',
              icon: Icons.settings,
              accentColor: AppTheme.secondaryColor,
              contentPadding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _parameters.map(_buildParameterField).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Novedades del turno
            CustomCard(
              title: 'Novedades del Turno',
              subtitle: 'Observaciones o eventos especiales',
              icon: Icons.comment,
              accentColor: AppTheme.accentColor,
              contentPadding: const EdgeInsets.all(16),
              child: _buildNotesField(),
            ),
            const SizedBox(height: 24),
            
            // Botón grande para guardar
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR REPORTE'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: plantColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    // Color para la planta seleccionada
    final plantColor = AppTheme.plantColors[widget.plant.id] ?? AppTheme.primaryColor;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con información de la planta
            CustomCard(
              showHeader: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [plantColor, plantColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPlantIcon(widget.plant.id),
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plant.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPlantDescription(widget.plant.id),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda: Información del turno y novedades
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      CustomCard(
                        title: 'Información del Turno',
                        subtitle: 'Datos generales del reporte',
                        icon: Icons.info_outline,
                        accentColor: AppTheme.primaryColor,
                        contentPadding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo para seleccionar fecha
                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Fecha',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _selectDate(context),
                                ),
                              ),
                              readOnly: true, // No permitir edición manual
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: 16),
                            _buildLeaderField(),
                            const SizedBox(height: 16),
                            _buildShiftDropdown(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        title: 'Novedades del Turno',
                        subtitle: 'Observaciones o eventos especiales',
                        icon: Icons.comment,
                        accentColor: AppTheme.accentColor,
                        contentPadding: const EdgeInsets.all(16),
                        child: _buildNotesField(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Columna derecha: Datos del proceso
                Expanded(
                  flex: 2,
                  child: CustomCard(
                    title: 'Datos del Proceso',
                    subtitle: 'Parámetros específicos para esta planta',
                    icon: Icons.settings,
                    accentColor: AppTheme.secondaryColor,
                    contentPadding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _parameters.map(_buildParameterField).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Botón grande para guardar
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR REPORTE'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: plantColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Reportador',
        border: OutlineInputBorder(),
      ),
      value: _selectedLeader,
      onChanged: (String? newValue) {
        setState(() {
          _selectedLeader = newValue!;
        });
      },
      items: _leader.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione un líder';
        }
        return null;
      },
    );
  }

  Widget _buildShiftDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Turno',
        border: OutlineInputBorder(),
      ),
      value: _selectedShift,
      onChanged: (String? newValue) {
        setState(() {
          _selectedShift = newValue!;
        });
      },
      items: _shifts.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Icon(
                _getShiftIcon(value),
                color: AppTheme.shiftColors[value],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParameterField(Map<String, dynamic> parameter) {
    final String fieldName = parameter['name'];
    final String fieldId = fieldName.toLowerCase().replaceAll(' ', '_');
    final String type = parameter['type'] ?? 'number';
    
    // Para campos de tipo dropdown
    if (type == 'dropdown') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: parameter['name'],
            border: const OutlineInputBorder(),
          ),
          items: (parameter['options'] as List).map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          value: _reportData[fieldId] ?? parameter['options'][0],
          onChanged: (String? value) {
            setState(() {
              _reportData[fieldId] = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor seleccione una opción';
            }
            return null;
          },
        ),
      );
    }
    
    // Para campos numéricos
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: '${parameter['name']} (${parameter['unit']})',
          border: const OutlineInputBorder(),
          helperText: 'Rango: ${parameter['min']} - ${parameter['max']}',
          prefixIcon: const Icon(Icons.trending_up),
          suffixText: parameter['unit'],
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        initialValue: _reportData[fieldId]?.toString() ?? '', // Inicializar con valor existente o vacío
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo requerido';
          }
          try {
            final double numValue = double.parse(value);
            if (numValue < parameter['min'] || numValue > parameter['max']) {
              return 'Valor fuera de rango';
            }
          } catch (e) {
            return 'Ingrese un número válido';
          }
          return null;
        },
        onSaved: (value) {
          // Guardar como número, no como string
          if (value != null && value.isNotEmpty) {
            try {
              _reportData[fieldId] = double.parse(value);
            } catch (e) {
              _reportData[fieldId] = 0.0; // Valor por defecto si hay error
            }
          } else {
            _reportData[fieldId] = 0.0; // Valor por defecto si está vacío
          }
        },
        onChanged: (value) {
          // Actualizar el valor en tiempo real
          if (value.isNotEmpty) {
            try {
              _reportData[fieldId] = double.parse(value);
            } catch (e) {
              // No actualizar si hay error de conversión
            }
          }
        },
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        hintText: 'Ingrese detalles de eventos inusuales, problemas o novedades durante el turno',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      minLines: 3,
      maxLines: 6,
      onSaved: (value) {
        _reportData['novedades'] = value ?? '';
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      _formKey.currentState!.save();

      // Procesamiento para asegurar tipos numéricos correctos
      final Map<String, dynamic> processedData = {};
      
      // Asegurar que todos los valores numéricos tengan el formato correcto
      _reportData.forEach((key, value) {
        if (value == null) {
          // Reemplazar nulos con valores predeterminados según el tipo de campo
          if (key.contains('produccion') || key.contains('reaccion') || 
              key.contains('cantidad') || key.contains('densidad')) {
            processedData[key] = 0.0;
          } else {
            processedData[key] = '';
          }
        } else if (value is String && key != 'referencia') {
          // Intentar convertir strings a números si no son referencias
          try {
            processedData[key] = double.parse(value);
          } catch (e) {
            // Si falla la conversión, mantener como string
            processedData[key] = value;
          }
        } else {
          // Mantener otros valores como están
          processedData[key] = value;
        }
      });
      
      // Eliminar las novedades del mapa de datos para evitar duplicación
      processedData.remove('novedades');
      
      try {
        // Crear nuevo reporte con la fecha seleccionada
        final newReport = Report(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 
                    DateTime.now().hour, DateTime.now().minute), // Usar la fecha seleccionada pero con la hora actual
          leader: _selectedLeader,
          shift: _selectedShift,
          plant: widget.plant,
          data: processedData, // Usar los datos procesados
          notes: _notesController.text,
        );
        
        // Guardar en la base de datos
        final result = await DatabaseHelper.instance.insertReport(newReport);
        
        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Reporte guardado correctamente'),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(16),
              ),
            );
            
            // Regresar a la pantalla anterior después de un breve retraso
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) {
              Navigator.pop(context);
              Navigator.pop(context); // Volver a la pantalla principal
            }
          }
        } else {
          throw Exception("No se pudo guardar el reporte");
        }
      } catch (e) {
        // ignore: avoid_print
        print("Error al guardar el reporte: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(16),
            ),
          );
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
  
  // Función para obtener descripción de la planta
  String _getPlantDescription(String id) {
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

  // Función para obtener icono de la planta
  IconData _getPlantIcon(String id) {
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