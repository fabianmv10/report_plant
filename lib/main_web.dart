import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container_web.dart';
import 'core/utils/logger.dart';
import 'features/plants/presentation/bloc/plants_bloc.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';

/// Punto de entrada principal de la aplicación para WEB
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la aplicación
  await _initializeApp();

  runApp(const MyApp());
}

/// Inicializar todos los servicios de la aplicación (versión WEB)
Future<void> _initializeApp() async {
  try {
    // 1. Cargar variables de entorno
    await AppConfig.initialize(envFile: '.env');
    logger.info('✅ Configuración cargada');

    // 2. Inicializar logger
    logger.initialize();
    logger.info('✅ Logger inicializado');

    // 3. Inicializar inyección de dependencias (versión web sin SQLite)
    await slWeb.init();
    logger.info('✅ Dependencias inicializadas (modo web - sin base de datos local)');

    logger.info('🌐 Aplicación web inicializada correctamente');
  } catch (e, stackTrace) {
    logger.fatal('❌ Error crítico al inicializar la aplicación', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Proveer BLoCs globales
        BlocProvider<PlantsBloc>(
          create: (_) => slWeb.plantsBloc..add(const PlantsEvent.loadPlants()),
        ),
        BlocProvider<ReportsBloc>(
          create: (_) => slWeb.reportsBloc,
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Reportes de Turno',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
