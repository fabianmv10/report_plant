import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../database/database_service.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../features/plants/data/datasources/plant_local_datasource.dart';
import '../../features/plants/data/datasources/plant_remote_datasource.dart';
import '../../features/plants/data/repositories/plant_repository_impl.dart';
import '../../features/plants/domain/repositories/plant_repository.dart';
import '../../features/plants/domain/usecases/get_all_plants.dart';
import '../../features/plants/presentation/bloc/plants_bloc.dart';

/// Contenedor de inyección de dependencias
/// Gestiona la creación e inyección de todas las dependencias de la app
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Singletons
  late final AppConfig appConfig;
  late final DioClient dioClient;
  late final DatabaseService databaseService;
  late final NetworkInfo networkInfo;
  late final Uuid uuid;

  // Repositories
  late final PlantRepository plantRepository;

  // Use cases
  late final GetAllPlants getAllPlants;

  // BLoCs (se crean bajo demanda)
  late final PlantsBloc plantsBloc;

  /// Inicializar todas las dependencias
  Future<void> init() async {
    // Core
    appConfig = AppConfig();
    dioClient = DioClient(appConfig);
    databaseService = DatabaseService();
    networkInfo = NetworkInfoImpl(Connectivity());
    uuid = const Uuid();

    // Obtener base de datos
    final Database db = await databaseService.database;

    // Data sources
    final plantRemoteDataSource = PlantRemoteDataSourceImpl(dioClient);
    final plantLocalDataSource = PlantLocalDataSourceImpl(db);

    // Repositories
    plantRepository = PlantRepositoryImpl(
      remoteDataSource: plantRemoteDataSource,
      localDataSource: plantLocalDataSource,
      networkInfo: networkInfo,
    );

    // Use cases
    getAllPlants = GetAllPlants(plantRepository);

    // BLoCs
    plantsBloc = PlantsBloc(getAllPlants: getAllPlants);
  }

  /// Limpiar recursos
  Future<void> dispose() async {
    await databaseService.close();
  }

  /// Reset (útil para testing)
  Future<void> reset() async {
    await dispose();
    await init();
  }
}

// Instancia global para fácil acceso
final sl = InjectionContainer();
