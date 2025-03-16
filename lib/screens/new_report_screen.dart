import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_helper.dart';
import '../widgets/responsive_layout.dart';

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
  
  final List<String> _shifts = ['Mañana', 'Tarde', 'Noche'];
  late List<Map<String, dynamic>> _parameters;

  @override
  void initState() {
    super.initState();
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

  final List<String> _leader = [
  'Andres Caballero',
  'Cesar Lopez',
  'Evelyn Meneses',
  'Faber Moncayo',
  'Lady Martinez',
  ];
  String _selectedLeader = 'Andres Caballero';

  List<Map<String, dynamic>> _getPlantParameters(String plantId) {
    // Aquí puedes definir parámetros específicos para cada planta
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
      case '3': // Banalum
        return [
          {'name': 'Producción Banalum', 'type': 'dropdown', 'options': ['Cristalizador 1', 'Cristalizador 2', 'Cristalizador 3']},
          {'name': 'Tipo', 'type': 'dropdown', 'options': ['Reacción', 'Recristalización', 'Descunche']},
          {'name': 'Referencia', 'type': 'dropdown', 'options': ['Banalum', 'Alumbre K']},
          {'name': 'Cristalizador Empaque', 'type': 'dropdown', 'options': ['Cristalizador 1', 'Cristalizador 2', 'Cristalizador 3']},
          {'name': 'Producción BAN Empaque', 'unit': 'Un', 'min': 0, 'max': 250},
          
        ];
      case '4': // Bisulfito de Sodio
        return [
          {'name': 'Estado Producción', 'type': 'dropdown', 'options': ['Sin Producción', 'Preparación','Reacción','Trasiego']},
          {'name': 'Cantidad Trasiego', 'unit': 'Kg', 'min': 0, 'max': 14000},
          {'name': 'pH Concentrador 1', 'unit': '', 'min': 4, 'max': 11},
          {'name': 'Densidad Concentrador 1', 'unit': 'gr/mL', 'min': 1.15, 'max': 1.40},
          {'name': 'pH Concentrador 2', 'unit': '', 'min': 4, 'max': 11},
          {'name': 'Densidad Concentrador 2', 'unit': 'gr/mL', 'min': 1.15, 'max': 1.40},
        ];
      case '5': // Silicatos
        return [
          {'name': 'Referencia', 'type': 'dropdown', 'options': ['Silicato Sodio P40', 'Silicato Sodio S50','Silicato Potasio K40','Silicato Potasio K47']},
          {'name': 'Cantidad', 'unit': 'Kg', 'min': 0, 'max': 15000},
          {'name': 'Baume', 'unit': '°Be', 'min': 0, 'max': 55},
          {'name': 'Presión', 'unit': 'psi', 'min': 0, 'max': 150},
        ];
      case '6': // Policloruro de Aluminio
        return [
          {'name': 'Reacción de CloAl', 'type': 'dropdown', 'options': ['Sin Reacción','Cloruro de Aluminio']},
          {'name': 'Cantidad Trasiego Tanque', 'unit': 'L', 'min': 0, 'max': 6000},
          {'name': 'Reacción de Policloruro', 'type': 'dropdown', 'options': ['Sin Reacción','Ultrafloc 100', 'Ultrafloc 200','Ultrafloc 300']},
          {'name': 'Cantidad Producto Filtrado', 'unit': 'L', 'min': 0, 'max': 8000},
          {'name': 'Densidad Producto Filtrado', 'unit': 'gr/mL', 'min': 1.28, 'max': 1.35},
        ];
      case '7': // Polimeros Cationicos
        return [
          {'name': 'Referencia', 'type': 'dropdown', 'options': ['Sin Reacción','Ultrabond 21032', 'Ultrabond 23032','Ultrabond 33005','Ultrafloc 4001/Rapised A','Ultrafloc 4002/Rapised B','Ultrafloc 4010']},
          {'name': 'Cantidad', 'unit': 'Kg', 'min': 0, 'max': 1},
          {'name': 'Densidad', 'unit': 'gr/mL', 'min': 1.08, 'max': 1.25},
          {'name': 'pH', 'unit': '', 'min': 3, 'max': 7},
          {'name': 'Solidos', 'unit': '%', 'min': 30, 'max': 70},
        ];
      case '8': // Polimeros Anionicos
        return [
          {'name': 'Referencia', 'type': 'dropdown', 'options': ['Sin Reacción','Ultrabond DC', 'Ultrabond 4010']},
          {'name': 'Cantidad', 'unit': 'Kg', 'min': 0, 'max': 1},
          {'name': 'Densidad', 'unit': 'gr/mL', 'min': 1.08, 'max': 1.25},
          {'name': 'pH', 'unit': '', 'min': 3, 'max': 7},
          {'name': 'Solidos', 'unit': '%', 'min': 30, 'max': 70},
        ];
      case '9': // Llenados
        return [
          {'name': 'Referencia', 'type': 'dropdown', 'options': [
            'Acido Clorhidrico 200 Kg',
            'Acido Clorhidrico 240 Kg',
            'Acido Fos 34,6% H3PO4 1200 Kg',
            'Acido Fos 55% H3PO4 250 kg',
            'Acido Fos 85% H3PO4 300 kg',
            'Acido Sulfurico 200 Kg',
            'Acido Sulfurico 250 Kg',
            'Bisulfito de Sodio 250 Kg',
            'Metasilicato de Sodio 250 Kg',
            'Rapised 4050 1000 Kg',
            'Rapised A 250 Kg',
            'Rapised A 1000 Kg',
            'Rapised B 250 Kg',
            'Rapised B 1100 Kg',
            'Silicato F47 250 Kg',
            'Silicato K40 250 Kg',
            'Silicato K40 1250 Kg',
            'Silicato K47 250 Kg',
            'Silicato P40 250 Kg',
            'Silicato P40 1250 Kg',
            'Silicato S50 250 Kg',
            'Sulfato Al TA 250 Kg',
            'Sulfato Al TA 1250 Kg',
            'Sulfato Al TB 250 Kg',
            'Sulfato Al TB 1300 Kg',
            'Ultrabond 21032 1050 Kg Exp',
            'Ultrabond 23032 1050 Kg Exp',
            'Ultrabond 4010 1000 Kg',
            'Ultrafloc 100 250 Kg', 
            'Ultrafloc 100 1250 Kg',
            'Ultrafloc 100 1300 Kg',
            'Ultrafloc 110 250 Kg',
            'Ultrafloc 110 1250 Kg',
            'Ultrafloc 200 1200 Kg',
            'Ultrafloc 300 250 Kg',
            'Ultrafloc 4002 240 Kg',
            'Ultrafloc 4002 1150 Kg',
            'Ultrafloc 4010 250 Kg',
            'Ultrafloc 4020 1000 Kg',

            ]},
          {'name': 'Unidades', 'unit': 'Un', 'min': 0, 'max': 50}
        ];
      // Casos para otras plantas...
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
    super.dispose();
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
      ),
      body: ResponsiveLayout(
        mobileLayout: _buildMobileLayout(),
        tabletLayout: _buildTabletLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormFields(),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con información de la planta
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plant.name,
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Información del Turno',
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildLeaderField(),
                              const SizedBox(height: 16),
                              _buildShiftDropdown(),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Novedades del Turno',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildNotesField(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Datos del proceso',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ..._parameters.map(_buildParameterField),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Información de la planta
      Text(
        widget.plant.name,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      const Text('Información del Turno',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _buildLeaderField(),
      const SizedBox(height: 16),
      _buildShiftDropdown(),
      const SizedBox(height: 24),
      const Text('Datos del Proceso',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      ..._parameters.map(_buildParameterField),
      const SizedBox(height: 24),
      const Text('Novedades del Turno',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _buildNotesField(),
    ];
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
          return 'Por favor seleccione un lider';
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
          child: Text(value),
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
        child: Row(
          children: [
            Expanded(
              flex: 3,
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
            ),
          ],
        ),
      );
    }
    
    // Para campos numéricos (comportamiento existente)
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: '${parameter['name']} (${parameter['unit']})',
                border: const OutlineInputBorder(),
                helperText: 'Rango: ${parameter['min']} - ${parameter['max']}',
              ),
              keyboardType: TextInputType.number,
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
                _reportData[fieldId] = double.parse(value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Observaciones y novedades',
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
      _formKey.currentState!.save();

      // Eliminar las novedades del mapa de datos para evitar duplicación
      _reportData.remove('novedades');
      
      // Verificar que todos los parámetros necesarios estén presentes
      bool allParamsPresent = true;
      for (var param in _parameters) {
        final String fieldId = param['name'].toString().toLowerCase().replaceAll(' ', '_');
        if (!_reportData.containsKey(fieldId) || _reportData[fieldId] == null) {
          allParamsPresent = false;
          print("Falta el parámetro: ${param['name']}");
        }
      }
      
      if (!allParamsPresent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faltan datos en el formulario')),
        );
        return;
      }

      // En _submitForm() antes de crear el reporte
      print("Datos del formulario: $_reportData");

      try {
        // Crear nuevo reporte
        final newReport = Report(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          leader: _selectedLeader,
          shift: _selectedShift,
          plant: widget.plant,
          data: _reportData,
          notes: _notesController.text,
        );
        
        // Guardar en la base de datos
        final result = await DatabaseHelper.instance.insertReport(newReport);
        
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reporte guardado correctamente')),
          );
          
          Navigator.pop(context);
          Navigator.pop(context); // Volver a la pantalla principal
        } else {
          throw Exception("No se pudo guardar el reporte");
        }
      } catch (e) {
        print("Error al guardar el reporte: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
        );
      }
    }
  }
}