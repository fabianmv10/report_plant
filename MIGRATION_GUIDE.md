# Guía de Migración - v1.0 a v2.0

Esta guía te ayudará a migrar tu código de la versión antigua a la nueva arquitectura.

## 📋 Índice

1. [Resumen de Cambios](#resumen-de-cambios)
2. [Configuración Inicial](#configuración-inicial)
3. [Migrando Modelos](#migrando-modelos)
4. [Migrando DatabaseHelper](#migrando-databasehelper)
5. [Migrando ApiService](#migrando-apiservice)
6. [Migrando Pantallas](#migrando-pantallas)
7. [Problemas Comunes](#problemas-comunes)

---

## Resumen de Cambios

### ❌ Código Antiguo
```
lib/
├── models/report.dart
├── services/
│   ├── database_helper.dart (usa mysql1 + sqflite)
│   ├── api_service.dart (conexión MySQL directa)
│   └── api_client.dart (REST API)
├── screens/
└── main.dart
```

### ✅ Código Nuevo
```
lib/
├── core/
│   ├── config/
│   ├── database/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── plants/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── reports/
├── theme/
└── main_new.dart
```

---

## Configuración Inicial

### 1. Instalar Nuevas Dependencias

```bash
flutter pub get
```

### 2. Configurar Variables de Entorno

Crear archivo `.env` en la raíz:

```bash
cp .env.example .env
```

Editar `.env`:

```env
API_BASE_URL=http://192.168.97.192:3000/api
API_TIMEOUT_SECONDS=30
REQUIRE_AUTH=false
LOG_LEVEL=debug
ENABLE_CRASH_REPORTING=false
ENABLE_OFFLINE_MODE=true
ENABLE_EXPORT=true
```

### 3. Generar Código

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Migrando Modelos

### ❌ Antes (models/report.dart)

```dart
class Plant {
  final String id;
  final String name;

  Plant({required this.id, required this.name});
}

class Report {
  final String id;
  final DateTime timestamp;
  final String leader;
  final String shift;
  final Plant plant;
  final Map<String, dynamic> data;
  final String? notes;

  Report({...});

  Map<String, dynamic> toJson() => {...};
  factory Report.fromJson(Map<String, dynamic> json) => ...;
}
```

### ✅ Después

```dart
// features/plants/domain/entities/plant.dart
@freezed
class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String name,
    DateTime? lastSynced,
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}

// features/reports/domain/entities/report.dart
@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required DateTime timestamp,
    required String leader,
    required String shift,
    required Plant plant,
    required Map<String, dynamic> data,
    String? notes,
    @Default(false) bool synced,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
```

**Cambios Clave:**
- Usar `@freezed` para inmutabilidad
- Agregar campo `synced` para rastrear sincronización
- JSON serialization automática con generación de código

---

## Migrando DatabaseHelper

### ❌ Antes

```dart
// Uso directo
final reports = await DatabaseHelper.instance.getAllReports();
await DatabaseHelper.instance.insertReport(report);
```

### ✅ Después

```dart
// Usar a través de BLoC
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.reportsBloc..add(ReportsEvent.loadReports()),
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          return state.when(
            initial: () => CircularProgressIndicator(),
            loading: () => CircularProgressIndicator(),
            loaded: (reports, hasReachedMax) => ReportsList(reports),
            error: (message) => ErrorWidget(message),
          );
        },
      ),
    );
  }
}

// Para crear un reporte
context.read<ReportsBloc>().add(
  ReportsEvent.createReport(reportData),
);
```

**Cambios Clave:**
- No acceder directamente a `DatabaseHelper`
- Usar BLoCs para gestión de estado
- Todo pasa a través de repositorios

---

## Migrando ApiService

### ❌ Antes (INSEGURO - eliminado)

```dart
import 'package:mysql1/mysql1.dart';

final connection = await MySqlConnection.connect(settings);
final results = await connection.query('SELECT * FROM reports');
```

### ✅ Después (SEGURO - solo API REST)

```dart
// Nunca acceder directamente, usar a través de repository
class PlantRepositoryImpl implements PlantRepository {
  final PlantRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Plant>>> getAllPlants() async {
    try {
      final plants = await remoteDataSource.getAllPlants();
      return Right(plants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

**Cambios Clave:**
- **NUNCA** usar `mysql1` directamente
- **SOLO** comunicación con API REST
- Manejo de errores con `Either<Failure, Success>`

---

## Migrando Pantallas

### ❌ Antes

```dart
class NewReportScreen extends StatefulWidget {
  @override
  _NewReportScreenState createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  Future<void> _submitForm() async {
    // Acceso directo a DatabaseHelper
    final result = await DatabaseHelper.instance.insertReport(report);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  }
}
```

### ✅ Después

```dart
class NewReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportFormCubit(
        createReport: sl.createReport,
      ),
      child: BlocListener<ReportFormCubit, ReportFormState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              ScaffoldMessenger.of(context).showSnackBar(...);
              Navigator.pop(context);
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        child: BlocBuilder<ReportFormCubit, ReportFormState>(
          builder: (context, state) => _buildForm(context, state),
        ),
      ),
    );
  }
}
```

**Cambios Clave:**
- Usar BLoC/Cubit para lógica de negocio
- `BlocListener` para side effects (navegación, snackbars)
- `BlocBuilder` para UI reactiva
- Separación de lógica y presentación

---

## Generación de IDs

### ❌ Antes

```dart
final id = DateTime.now().millisecondsSinceEpoch.toString();
```

### ✅ Después

```dart
import 'package:uuid/uuid.dart';

final uuid = Uuid();
final id = uuid.v4(); // e.g., "550e8400-e29b-41d4-a716-446655440000"
```

---

## Logging

### ❌ Antes

```dart
print('Error: $e');
print('Reporte guardado');
```

### ✅ Después

```dart
import 'package:report_plant/core/utils/logger.dart';

logger.info('Reporte guardado');
logger.error('Error al guardar reporte', e, stackTrace);
logger.debug('Datos del reporte: $data');
```

---

## Acceso a Configuración

### ❌ Antes

```dart
const String baseUrl = 'http://192.168.97.192:3000/api'; // Hardcoded
```

### ✅ Después

```dart
import 'package:report_plant/core/config/app_config.dart';

final config = AppConfig();
final baseUrl = config.apiBaseUrl; // De .env
```

---

## Problemas Comunes

### 1. "The getter 'instance' isn't defined"

**Problema:** Intentando usar singleton antiguo

```dart
// ❌ Antiguo
DatabaseHelper.instance.getAllReports()
```

**Solución:** Usar BLoC

```dart
// ✅ Nuevo
context.read<ReportsBloc>().add(ReportsEvent.loadReports());
```

---

### 2. "Type 'Plant' is not a subtype of type 'Plant'"

**Problema:** Mezclando modelos antiguos y nuevos

**Solución:** Asegurarse de usar solo modelos nuevos de `features/.../domain/entities/`

---

### 3. "The method 'toJson' isn't defined"

**Problema:** No se generó el código Freezed

**Solución:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 4. "dotenv not loaded"

**Problema:** No se inicializó AppConfig

**Solución:** En `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(); // ← Importante
  await sl.init();
  runApp(MyApp());
}
```

---

### 5. "No implementation found for method X"

**Problema:** Canal de plataforma no inicializado

**Solución:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← Agregar
  // ...
}
```

---

## Checklist de Migración

- [ ] Instalar dependencias nuevas
- [ ] Configurar `.env`
- [ ] Generar código Freezed
- [ ] Actualizar imports
- [ ] Reemplazar acceso directo a `DatabaseHelper` con BLoCs
- [ ] Eliminar código que use `mysql1`
- [ ] Reemplazar `print()` con `logger`
- [ ] Actualizar generación de IDs a UUID
- [ ] Ejecutar tests
- [ ] Probar en dispositivo físico
- [ ] Verificar modo offline
- [ ] Verificar sincronización

---

## Ayuda Adicional

Si encuentras problemas:

1. Consulta los ejemplos en la carpeta `test/`
2. Revisa la documentación en `README.md`
3. Busca en el código nuevo cómo se implementa lo que necesitas
4. Crea un issue en GitHub con detalles del problema

---

**¡Buena suerte con la migración! 🚀**
