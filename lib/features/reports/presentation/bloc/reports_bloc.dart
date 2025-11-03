import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/get_reports.dart';
import '../../domain/usecases/create_report.dart';

part 'reports_event.dart';
part 'reports_state.dart';
part 'reports_bloc.freezed.dart';

/// BLoC para gestionar el estado de los reportes
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReports getReports;
  final GetReportsByPlant getReportsByPlant;
  final CreateReport createReport;
  final SyncPendingReports syncPendingReports;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasReachedMax = false;

  ReportsBloc({
    required this.getReports,
    required this.getReportsByPlant,
    required this.createReport,
    required this.syncPendingReports,
  }) : super(const ReportsState.initial()) {
    on<ReportsEvent>((event, emit) async {
      await event.when(
        loadReports: () => _onLoadReports(emit),
        loadMoreReports: () => _onLoadMoreReports(emit),
        refreshReports: () => _onRefreshReports(emit),
        filterByPlant: (plantId) => _onFilterByPlant(emit, plantId),
        syncReports: () => _onSyncReports(emit),
      );
    });
  }

  Future<void> _onLoadReports(Emitter<ReportsState> emit) async {
    emit(const ReportsState.loading());
    _currentPage = 1;
    _hasReachedMax = false;

    final result = await getReports(page: _currentPage, pageSize: _pageSize);

    result.fold(
      (failure) {
        logger.error('Error al cargar reportes: ${failure.message}');
        emit(ReportsState.error(failure.message));
      },
      (reports) {
        logger.info('Reportes cargados: ${reports.length}');
        _hasReachedMax = reports.length < _pageSize;
        emit(ReportsState.loaded(
          reports,
          hasReachedMax: _hasReachedMax,
        ));
      },
    );
  }

  Future<void> _onLoadMoreReports(Emitter<ReportsState> emit) async {
    final currentState = state;

    if (currentState is _Loaded && !_hasReachedMax) {
      _currentPage++;

      final result = await getReports(page: _currentPage, pageSize: _pageSize);

      result.fold(
        (failure) {
          logger.error('Error al cargar más reportes: ${failure.message}');
          // Mantener el estado actual
        },
        (newReports) {
          logger.info('Más reportes cargados: ${newReports.length}');
          _hasReachedMax = newReports.length < _pageSize;

          final allReports = [...currentState.reports, ...newReports];
          emit(ReportsState.loaded(
            allReports,
            hasReachedMax: _hasReachedMax,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshReports(Emitter<ReportsState> emit) async {
    _currentPage = 1;
    _hasReachedMax = false;

    final result = await getReports(page: _currentPage, pageSize: _pageSize);

    result.fold(
      (failure) {
        logger.error('Error al refrescar reportes: ${failure.message}');
        final currentState = state;
        if (currentState is _Loaded) {
          emit(currentState); // Mantener estado actual
        } else {
          emit(ReportsState.error(failure.message));
        }
      },
      (reports) {
        logger.info('Reportes refrescados: ${reports.length}');
        _hasReachedMax = reports.length < _pageSize;
        emit(ReportsState.loaded(
          reports,
          hasReachedMax: _hasReachedMax,
        ));
      },
    );
  }

  Future<void> _onFilterByPlant(
    Emitter<ReportsState> emit,
    String plantId,
  ) async {
    emit(const ReportsState.loading());
    _currentPage = 1;
    _hasReachedMax = false;

    final result = await getReportsByPlant(
      plantId,
      page: _currentPage,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) {
        logger.error('Error al filtrar reportes: ${failure.message}');
        emit(ReportsState.error(failure.message));
      },
      (reports) {
        logger.info('Reportes filtrados: ${reports.length}');
        _hasReachedMax = reports.length < _pageSize;
        emit(ReportsState.loaded(
          reports,
          hasReachedMax: _hasReachedMax,
          filteredByPlant: plantId,
        ));
      },
    );
  }

  Future<void> _onSyncReports(Emitter<ReportsState> emit) async {
    final currentState = state;

    emit(const ReportsState.syncing());

    final result = await syncPendingReports();

    result.fold(
      (failure) {
        logger.error('Error al sincronizar: ${failure.message}');
        if (currentState is _Loaded) {
          emit(currentState);
        } else {
          emit(ReportsState.error(failure.message));
        }
      },
      (syncResult) {
        logger.info('Sincronización completada: $syncResult');
        // Recargar reportes después de sincronizar
        add(const ReportsEvent.loadReports());
      },
    );
  }
}
