import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../features/plants/data/datasources/plant_remote_datasource.dart';
import '../../features/plants/data/repositories/plant_repository_impl_web.dart';
import '../../features/plants/domain/repositories/plant_repository.dart';
import '../../features/plants/domain/usecases/get_all_plants.dart';
import '../../features/plants/presentation/bloc/plants_bloc.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl_web.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/create_report.dart';
import '../../features/reports/domain/usecases/get_reports.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';

/// Contenedor de inyección de dependencias para WEB
/// (Sin soporte para base de datos local SQLite)
class InjectionContainerWeb {
  static final InjectionContainerWeb _instance = InjectionContainerWeb._internal();
  factory InjectionContainerWeb() => _instance;
  InjectionContainerWeb._internal();

  // Singletons
  late final AppConfig appConfig;
  late final DioClient dioClient;
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

  /// Inicializar todas las dependencias (versión WEB sin SQLite)
  Future<void> init() async {
    // Core
    appConfig = AppConfig();
    dioClient = DioClient(appConfig);
    networkInfo = NetworkInfoImpl(Connectivity());
    uuid = const Uuid();

    // Data sources - Solo remotos (sin local storage en web)
    final plantRemoteDataSource = PlantRemoteDataSourceImpl(dioClient);
    final reportRemoteDataSource = ReportRemoteDataSourceImpl(dioClient);

    // Repositories (versión web sin base de datos local)
    plantRepository = PlantRepositoryImplWeb(
      remoteDataSource: plantRemoteDataSource,
      networkInfo: networkInfo,
    );

    reportRepository = ReportRepositoryImplWeb(
      remoteDataSource: reportRemoteDataSource,
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
    // En web no hay recursos de base de datos que cerrar
  }

  /// Reset (útil para testing)
  Future<void> reset() async {
    await dispose();
    await init();
  }
}

// Instancia global para fácil acceso
final slWeb = InjectionContainerWeb();
