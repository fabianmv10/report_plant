class PlantParameters {
  /// Obtener los parámetros para una planta específica
  static List<Map<String, dynamic>> getParameters(String plantId) {
    switch (plantId) {
      case '1': // Sulfato de Aluminio Tipo A
        return [
          {'name': 'Referencia', 'type': 'dropdown', 'options': ['SATA x 25 Kg', 'SATA IF x 25 Kg', 'SATA IF x 1000 Kg']},
          {'name': 'Producción STAS 1ra Reacción', 'unit': 'Un', 'min': 0, 'max': 150},
          {'name': 'Producción STAS 2da Reacción', 'unit': 'Un', 'min': 0, 'max': 150},
          {'name': 'Producción Liquida', 'unit': 'kg', 'min': 0, 'max': 16000},
        ];
      case '2': // Sulfato de Aluminio Tipo B
        return [
          {'name': 'Reacción de STBS', 'unit': 'Reacción', 'min': 0, 'max': 2},
          {'name': 'Producción STBS Empaque', 'unit': 'Un', 'min': 0, 'max': 300},
          {'name': 'Reacción de STBL', 'unit': 'Reacción', 'min': 0, 'max': 2},
          {'name': 'Decantador de STBL','type': 'dropdown', 'options': ['Decantador 1', 'Decantador 2']},
          {'name': 'Producción STBL Tanque', 'unit': 'Kg', 'min': 0, 'max': 50000},
          {'name': 'Tanque de STBL','type': 'dropdown', 'options': ['Tanque 1', 'Tanque 2', 'Tanque 3', 'Tanque 4']},
        ];
      case '3': // Banalum
        return [
          {'name': 'Referencia Reacción', 'type': 'dropdown', 'options': ['Sin Reacción','Banalum', 'Alumbre K']},
          {'name': 'Tipo Producción', 'type': 'dropdown', 'options': ['Sin Reacción','Reacción', 'Recristalización', 'Descunche']},
          {'name': 'Equipo Reacción', 'type': 'dropdown', 'options': ['Sin Reacción','Cristalizador 1', 'Cristalizador 2', 'Cristalizador 3']},
          {'name': 'Tipo Empaque', 'type': 'dropdown', 'options': ['Reacción', 'Recristalización', 'Descunche']},
          {'name': 'Cristalizador Empaque', 'type': 'dropdown', 'options': ['Cristalizador 1', 'Cristalizador 2', 'Cristalizador 3']},
          {'name': 'Producción Empaque', 'unit': 'Un', 'min': 0, 'max': 250},
        ];
      case '4': // Bisulfito de Sodio
        return [
          {'name': 'Estado Producción', 'type': 'dropdown', 'options': ['Sin Producción', 'Preparación','Reacción','Trasiego']},
          {'name': 'Producción Bisulfito', 'unit': 'Kg', 'min': 0, 'max': 14000},
          {'name': 'pH Concentrador 1', 'unit': '', 'min': 4, 'max': 11},
          {'name': 'Densidad Concentrador 1', 'unit': 'gr/mL', 'min': 1.15, 'max': 1.40},
          {'name': 'pH Concentrador 2', 'unit': '', 'min': 4, 'max': 11},
          {'name': 'Densidad Concentrador 2', 'unit': 'gr/mL', 'min': 1.15, 'max': 1.40},
        ];
      case '5': // Silicatos
        return [
          {'name': 'Referencia Reacción', 'type': 'dropdown', 'options': ['Silicato Sodio P40', 'Silicato Sodio S50','Silicato Potasio K40','Silicato Potasio K47']},
          {'name': 'Reacción de Silicato', 'unit': 'Reacción', 'min': 0, 'max': 2},
          {'name': 'Producción de Silicato', 'unit': 'Kg', 'min': 0, 'max': 15000},
          {'name': 'Baume', 'unit': '°Be', 'min': 0, 'max': 55},
          {'name': 'Presión', 'unit': 'psi', 'min': 0, 'max': 150},
        ];
      case '6': // Policloruro de Aluminio
        return [
          {'name': 'Reacción de CloAl', 'type': 'dropdown', 'options': ['Sin Reacción','Cloruro de Aluminio']},
          {'name': 'Producción CloAl', 'unit': 'L', 'min': 0, 'max': 6000},
          {'name': 'Densidad CloAl', 'unit': 'L', 'min': 0, 'max': 6000},
          {'name': 'Reacción de Policloruro', 'type': 'dropdown', 'options': ['Sin Reacción','Ultrafloc 100', 'Ultrafloc 200','Ultrafloc 300']},
          {'name': 'Producción Policloruro', 'unit': 'L', 'min': 0, 'max': 8000},
          {'name': 'Densidad Policloruro', 'unit': 'gr/mL', 'min': 1.28, 'max': 1.35},
        ];
      case '7': // Polimeros Cationicos
        return [
          {'name': 'Referencia Reacción', 'type': 'dropdown', 'options': ['Sin Reacción','Ultrabond 21032', 'Ultrabond 23032','Ultrabond 33005','Ultrafloc 4001/Rapised A','Ultrafloc 4002/Rapised B','Ultrafloc 4010']},
          {'name': 'Producción Polimero', 'unit': 'Kg', 'min': 0, 'max': 1},
          {'name': 'Densidad Polimero', 'unit': 'gr/mL', 'min': 1.08, 'max': 1.25},
          {'name': 'pH Polimero', 'unit': '', 'min': 3, 'max': 7},
          {'name': 'Solidos Polimero', 'unit': '%', 'min': 30, 'max': 70},
        ];
      case '8': // Polimeros Anionicos
        return [
          {'name': 'Referencia Reacción', 'type': 'dropdown', 'options': ['Sin Reacción','Ultrabond DC', 'Ultrabond 4010']},
          {'name': 'Producción Polimero', 'unit': 'Kg', 'min': 0, 'max': 1},
          {'name': 'Densidad Polimero', 'unit': 'gr/mL', 'min': 1.08, 'max': 1.25},
          {'name': 'pH Polimero', 'unit': '', 'min': 3, 'max': 7},
          {'name': 'Solidos Polimero', 'unit': '%', 'min': 30, 'max': 70},
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
      default:
        return [
          {'name': 'Temperatura', 'unit': '°C', 'min': 30, 'max': 90},
          {'name': 'Presión', 'unit': 'bar', 'min': 1, 'max': 5},
          {'name': 'pH', 'unit': '', 'min': 5, 'max': 9},
          {'name': 'Nivel de tanque', 'unit': '%', 'min': 0, 'max': 100},
        ];
    }
  }
  
  /// Obtener el nombre de la planta por ID
  static String getPlantName(String plantId) {
    switch (plantId) {
      case '1': return 'Sulfato de Aluminio Tipo A';
      case '2': return 'Sulfato de Aluminio Tipo B';
      case '3': return 'Banalum';
      case '4': return 'Bisulfito de Sodio';
      case '5': return 'Silicatos';
      case '6': return 'Policloruro de Aluminio';
      case '7': return 'Polímeros Catiónicos';
      case '8': return 'Polímeros Aniónicos';
      case '9': return 'Llenados';
      default: return 'Planta Genérica';
    }
  }
  
  /// Convertir un nombre de campo a formato legible
  static String formatFieldName(String fieldName) {
    return fieldName
        .split('_')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');
  }
  
  /// Obtener icono para la planta según ID
  static int getPlantIcon(String id) {
    switch (id) {
      case '1': 
      case '2': return 0xE5ED; // water_drop: 0xE5ED
      case '3': return 0xE3E4; // agriculture: 0xE3E4
      case '4': return 0xE26C; // science: 0xE26C
      case '5': return 0xE53A; // bubble_chart: 0xE53A
      case '6': return 0xE3DD; // factory: 0xE3DD
      case '7': 
      case '8': return 0xE40C; // polymer: 0xE40C
      case '9': return 0xE179; // inventory: 0xE179
      default: return 0xE584; // spa: 0xE584
    }
  }
  
  /// Obtener icono para el turno
  static int getShiftIcon(String shift) {
    switch (shift) {
      case 'Mañana': return 0xE430; // wb_sunny: 0xE430
      case 'Tarde': return 0xEC0F; // wb_twilight: 0xEC0F
      case 'Noche': return 0xE3A8; // nightlight_round: 0xE3A8
      default: return 0xE192; // access_time: 0xE192
    }
  }
}