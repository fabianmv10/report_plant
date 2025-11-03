import 'package:connectivity_plus/connectivity_plus.dart';
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
import '../../features/reports/data/datasources/report_local_datasource.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/create_report.dart';
import '../../features/reports/domain/usecases/get_reports.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';

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
  late final ReportRepository reportRepository;

  // Use cases - Plants
  late final GetAllPlants getAllPlants;

  // Use cases - Reports
  late final GetReports getReports;
  late final GetReportsByPlant getReportsByPlant;
  late final CreateReport createReport;
  late final SyncPendingReports syncPendingReports;

  // BLoCs (se crean bajo demanda)
  late final PlantsBloc plantsBloc;
  late final ReportsBloc reportsBloc;

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

    // Data sources - Plants
    final plantRemoteDataSource = PlantRemoteDataSourceImpl(dioClient);
    final plantLocalDataSource = PlantLocalDataSourceImpl(db);

    // Data sources - Reports
    final reportRemoteDataSource = ReportRemoteDataSourceImpl(dioClient);
    final reportLocalDataSource = ReportLocalDataSourceImpl(db);

    // Repositories
    plantRepository = PlantRepositoryImpl(
      remoteDataSource: plantRemoteDataSource,
      localDataSource: plantLocalDataSource,
      networkInfo: networkInfo,
    );

    reportRepository = ReportRepositoryImpl(
      remoteDataSource: reportRemoteDataSource,
      localDataSource: reportLocalDataSource,
      networkInfo: networkInfo,
    );

    // Use cases - Plants
    getAllPlants = GetAllPlants(plantRepository);

    // Use cases - Reports
    getReports = GetReports(reportRepository);
    getReportsByPlant = GetReportsByPlant(reportRepository);
    createReport = CreateReport(reportRepository, uuid);
    syncPendingReports = SyncPendingReports(reportRepository);

    // BLoCs
    plantsBloc = PlantsBloc(getAllPlants: getAllPlants);
    reportsBloc = ReportsBloc(
      getReports: getReports,
      getReportsByPlant: getReportsByPlant,
      createReport: createReport,
      syncPendingReports: syncPendingReports,
    );
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
