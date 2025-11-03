# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [2.0.0] - 2025-01-XX

### 🎉 Refactorización Mayor - Clean Architecture

Esta versión incluye una refactorización completa de la aplicación siguiendo principios de Clean Architecture.

### ✨ Agregado

- **Arquitectura Clean**: Implementación completa de Clean Architecture
  - Separación en capas: Domain, Data, Presentation
  - Use Cases para encapsular lógica de negocio
  - Repositories abstractos en capa de dominio

- **Sistema de Configuración**
  - Variables de entorno con `flutter_dotenv`
  - Archivos `.env`, `.env.dev`, `.env.prod`
  - Configuración centralizada en `AppConfig`

- **Sistema de Logging Profesional**
  - Logger centralizado con niveles (debug, info, warning, error, fatal)
  - Logs con colores y timestamps
  - Configuración por entorno

- **Manejo de Errores Mejorado**
  - Failures para la capa de dominio
  - Exceptions para la capa de datos
  - Conversión automática de excepciones a failures
  - Mensajes de error más descriptivos

- **Gestión de Estado con BLoC**
  - `PlantsBloc` para gestión de plantas
  - `ReportsBloc` para gestión de reportes con paginación
  - Estados inmutables con Freezed
  - Separación clara de eventos y estados

- **Networking Mejorado**
  - Cliente HTTP centralizado con Dio
  - Interceptores para logging
  - Manejo de timeouts configurable
  - Soporte para autenticación JWT

- **Base de Datos con Migraciones**
  - Sistema de migraciones automáticas
  - Versionado de base de datos
  - Índices para mejorar rendimiento
  - Soporte para upgrades y downgrades

- **Modelos Inmutables**
  - Uso de Freezed para modelos de datos
  - JSON serialization automática
  - Copyable y equality por defecto
  - Type-safe

- **Inyección de Dependencias**
  - Contenedor de dependencias centralizado
  - Inicialización ordenada
  - Fácil testing y mocking

- **Testing**
  - Tests unitarios para use cases
  - Tests de BLoC con `bloc_test`
  - Mocks con Mockito
  - Estructura de tests organizada

- **Paginación**
  - Soporte para paginación en reportes
  - Lazy loading de datos
  - Indicador de "fin de lista"

- **UUIDs**
  - Generación de IDs únicos con paquete UUID
  - Elimina riesgo de colisiones

- **Widget de Conectividad**
  - Banner que muestra estado de conexión
  - Notificación cuando se recupera conexión
  - Integración con NetworkInfo

- **Documentación Completa**
  - README.md mejorado
  - CHANGELOG.md
  - Guía de migración
  - Documentación de arquitectura

### 🔄 Cambiado

- **Dependencias Actualizadas**
  - `connectivity_plus`: ^4.0.2 → ^5.0.2
  - `dio`: ^5.3.2 → ^5.4.0
  - `http`: ^0.13.5 → ^1.1.2
  - `path`: ^1.8.3 → ^1.9.0

### 🗑️ Eliminado

- **Paquete mysql1**: Eliminado por razones de seguridad
  - ❌ No más conexión directa a MySQL desde app móvil
  - ✅ Toda comunicación ahora a través de API REST

- **Credenciales Hardcodeadas**: Todas removidas
  - Host de base de datos
  - Usuario y contraseña
  - Ahora se usan variables de entorno

- **dart_code_metrics**: Paquete deprecado eliminado
  - Reemplazado por configuración de análisis estándar

- **Código Duplicado**
  - Métodos `_insertPlantSpecificData` y `_insertPlantSpecificDataSimple` consolidados
  - Lógica de conversión de datos centralizada

### 🔒 Seguridad

- **Eliminación de Riesgos Críticos**
  - Sin credenciales de BD en código fuente
  - Sin acceso directo a base de datos desde app
  - Variables sensibles en archivos `.env` (gitignored)

- **Mejoras de Autenticación**
  - Estructura preparada para JWT
  - Repository de autenticación implementado
  - Almacenamiento seguro de tokens

### 🐛 Corregido

- Problemas de conexión MySQL directa
- Generación de IDs con posibles colisiones
- Falta de manejo de errores en capa de red
- Prints en lugar de sistema de logging
- Código con warnings de análisis estático

### 📚 Notas de Migración

**⚠️ IMPORTANTE**: Esta es una versión mayor con cambios no compatibles hacia atrás.

Ver `MIGRATION_GUIDE.md` para instrucciones detalladas de migración.

#### Pasos Rápidos

1. Actualizar dependencias: `flutter pub get`
2. Generar código: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Configurar `.env` basándose en `.env.example`
4. Actualizar imports y uso de modelos
5. Ejecutar tests: `flutter test`

---

## [1.0.0] - 2024-XX-XX

### Inicial

- Implementación básica de la aplicación
- CRUD de reportes
- Múltiples plantas
- Modo offline básico
- Exportación a CSV/JSON
- Temas claro/oscuro
