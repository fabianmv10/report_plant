# Report Plant - Aplicación de Reportes de Turno

Aplicación móvil Flutter para gestionar reportes de turno en plantas industriales, con soporte offline, sincronización automática y arquitectura escalable.

## 🚀 Características

- ✅ **Arquitectura Clean Architecture** - Código mantenible y testeable
- 🔐 **Autenticación JWT** - Sistema seguro de login
- 📡 **Modo Offline** - Funciona sin conexión, sincroniza automáticamente
- 🎨 **UI/UX Moderna** - Tema claro/oscuro, responsive design
- 📊 **Gestión de Reportes** - Crear, ver, editar y exportar reportes
- 🏭 **Múltiples Plantas** - Soporte para diferentes tipos de plantas industriales
- 📥 **Exportación** - CSV y JSON para análisis de datos
- 🔄 **Sincronización Automática** - Reportes pendientes se sincronizan al recuperar conexión
- 🧪 **Testing** - Tests unitarios y de integración
- 📝 **Logging Profesional** - Sistema centralizado de logs

## 📋 Requisitos Previos

- Flutter SDK >= 3.5.4
- Dart SDK >= 3.5.4
- Android Studio / VS Code
- Node.js >= 18 (para el backend)

## 🛠️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/report_plant.git
cd report_plant
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Copiar el archivo de ejemplo y configurar:

```bash
cp .env.example .env
```

Editar `.env` con tu configuración:

```env
API_BASE_URL=http://tu-servidor:3000/api
API_TIMEOUT_SECONDS=30
REQUIRE_AUTH=true
LOG_LEVEL=debug
```

### 4. Generar código (modelos, BLoCs)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Ejecutar la aplicación

```bash
flutter run
```

## 🏗️ Arquitectura

Este proyecto sigue **Clean Architecture** con las siguientes capas:

```
lib/
├── core/                       # Código compartido
│   ├── config/                 # Configuración de la app
│   ├── database/               # Servicio de BD con migraciones
│   ├── di/                     # Inyección de dependencias
│   ├── errors/                 # Manejo de errores
│   ├── network/                # Cliente HTTP
│   ├── utils/                  # Utilidades
│   └── widgets/                # Widgets reutilizables
│
├── features/                   # Características por dominio
│   ├── auth/                   # Autenticación
│   │   ├── data/               # Fuentes de datos, modelos
│   │   ├── domain/             # Entidades, repositorios, casos de uso
│   │   └── presentation/       # BLoC, páginas, widgets
│   │
│   ├── plants/                 # Gestión de plantas
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── reports/                # Gestión de reportes
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── theme/                      # Temas y estilos
└── main.dart                   # Punto de entrada
```

### Principios Aplicados

- **SOLID** - Principios de diseño orientado a objetos
- **DRY** - Don't Repeat Yourself
- **Separation of Concerns** - Separación de responsabilidades
- **Dependency Injection** - Inversión de dependencias
- **Repository Pattern** - Abstracción de fuentes de datos
- **BLoC Pattern** - Gestión de estado predecible

## 🔒 Seguridad

### ✅ Implementado

- Variables de entorno para credenciales
- Autenticación JWT
- Validación de datos en cliente y servidor
- Solo comunicación con API REST (sin acceso directo a BD)
- Tokens con expiración

### ⚠️ Recomendaciones para Producción

1. **Usar HTTPS** - Configurar certificados SSL/TLS
2. **Implementar Refresh Tokens** - Para sesiones largas
3. **Rate Limiting** - En el backend
4. **Encriptación de BD Local** - Para datos sensibles
5. **Certificate Pinning** - Para prevenir MITM

## 📊 Base de Datos

### Estructura SQLite Local

```sql
-- Plantas
CREATE TABLE plants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  last_synced INTEGER
);

-- Reportes
CREATE TABLE reports (
  id TEXT PRIMARY KEY,
  timestamp INTEGER NOT NULL,
  leader TEXT NOT NULL,
  shift TEXT NOT NULL,
  plant_id TEXT NOT NULL,
  data TEXT NOT NULL,
  notes TEXT,
  synced INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (plant_id) REFERENCES plants (id)
);
```

### Migraciones

El sistema soporta migraciones automáticas. Para agregar una:

1. Incrementar `_databaseVersion` en `database_service.dart`
2. Agregar nueva migración en `migrations.dart`

## 🧪 Testing

### Ejecutar todos los tests

```bash
flutter test
```

### Ejecutar tests con coverage

```bash
flutter test --coverage
```

### Generar reporte de coverage

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📦 Dependencias Principales

### Producción

- `flutter_bloc` - Gestión de estado
- `dio` - Cliente HTTP
- `sqflite` - Base de datos local
- `freezed` - Modelos inmutables
- `dartz` - Programación funcional
- `uuid` - Generación de IDs únicos
- `logger` - Sistema de logging

### Desarrollo

- `mockito` - Mocking para tests
- `bloc_test` - Testing de BLoCs
- `build_runner` - Generación de código

## 🔄 CI/CD

### GitHub Actions (Ejemplo)

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
```

## 📱 Build para Producción

### Android

```bash
flutter build apk --release
# o para App Bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🐛 Debugging

### Logs

Los logs se categorizan por nivel:
- `debug` - Información detallada para debugging
- `info` - Información general
- `warning` - Advertencias
- `error` - Errores recuperables
- `fatal` - Errores críticos

### Ver logs en tiempo real

```bash
flutter logs
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

### Estándares de Código

- Seguir guía de estilo de Dart
- 100% cobertura de tests para lógica de negocio
- Documentar funciones públicas
- Usar commits semánticos

## 📄 Licencia

Este proyecto es privado y propietario.

## 🗺️ Roadmap

- [ ] Notificaciones push
- [ ] Gráficas y análisis de datos
- [ ] Modo oscuro automático
- [ ] Integración con sensores IoT
- [ ] Dashboard web administrativo
- [ ] Exportación a Excel
- [ ] Firma digital de reportes
- [ ] Adjuntar fotos a reportes

## 📚 Recursos

- [Documentación Flutter](https://flutter.dev/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
