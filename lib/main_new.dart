import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'features/plants/presentation/bloc/plants_bloc.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Punto de entrada principal de la aplicación (versión mejorada)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar configuración
  await _initializeApp();

  runApp(const MyApp());
}

/// Inicializar la aplicación
Future<void> _initializeApp() async {
  try {
    // 1. Cargar variables de entorno
    await AppConfig.initialize(envFile: '.env');
    logger.info('Configuración cargada');

    // 2. Inicializar logger
    logger.initialize();
    logger.info('Logger inicializado');

    // 3. Inicializar inyección de dependencias
    await sl.init();
    logger.info('Dependencias inicializadas');

    logger.info('Aplicación inicializada correctamente');
  } catch (e, stackTrace) {
    logger.fatal('Error crítico al inicializar la aplicación', e, stackTrace);
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
          create: (_) => sl.plantsBloc..add(const PlantsEvent.loadPlants()),
        ),
        // Agregar más BLoCs según sea necesario
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
