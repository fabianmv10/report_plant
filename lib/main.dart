import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'core/widgets/connectivity_banner.dart';
import 'features/plants/presentation/bloc/plants_bloc.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';

/// Punto de entrada principal de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la aplicación
  await _initializeApp();

  runApp(const MyApp());
}

/// Inicializar todos los servicios de la aplicación
Future<void> _initializeApp() async {
  try {
    // 1. Cargar variables de entorno
    await AppConfig.initialize(envFile: '.env');

    // 2. Inicializar logger PRIMERO antes de usarlo
    logger.initialize();
    logger.info('✅ Configuración cargada');
    logger.info('✅ Logger inicializado');

    // 3. Inicializar inyección de dependencias
    await sl.init();
    logger.info('✅ Dependencias inicializadas');

    // 4. Sincronizar reportes pendientes
    try {
      await sl.syncPendingReports();
      logger.info('✅ Reportes sincronizados');
    } catch (e) {
      logger.warning('⚠️ No se pudieron sincronizar reportes', e);
    }

    logger.info('🚀 Aplicación inicializada correctamente');
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
          create: (_) => sl.plantsBloc..add(const PlantsEvent.loadPlants()),
        ),
        BlocProvider<ReportsBloc>(
          create: (_) => sl.reportsBloc,
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
              home: ConnectivityBanner(
                networkInfo: sl.networkInfo,
                child: const HomeScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
