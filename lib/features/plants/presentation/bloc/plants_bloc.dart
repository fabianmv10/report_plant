import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_all_plants.dart';

part 'plants_event.dart';
part 'plants_state.dart';
part 'plants_bloc.freezed.dart';

/// BLoC para gestionar el estado de las plantas
class PlantsBloc extends Bloc<PlantsEvent, PlantsState> {
  final GetAllPlants getAllPlants;

  PlantsBloc({
    required this.getAllPlants,
  }) : super(const PlantsState.initial()) {
    on<PlantsEvent>((event, emit) async {
      await event.when(
        loadPlants: () => _onLoadPlants(emit),
        refreshPlants: () => _onRefreshPlants(emit),
      );
    });
  }

  Future<void> _onLoadPlants(Emitter<PlantsState> emit) async {
    emit(const PlantsState.loading());

    final result = await getAllPlants();

    result.fold(
      (failure) {
        logger.error('Error al cargar plantas: ${failure.message}');
        emit(PlantsState.error(failure.message));
      },
      (plants) {
        logger.info('Plantas cargadas: ${plants.length}');
        emit(PlantsState.loaded(plants));
      },
    );
  }

  Future<void> _onRefreshPlants(Emitter<PlantsState> emit) async {
    // Mantener el estado actual mientras se refresca
    final currentState = state;

    final result = await getAllPlants();

    result.fold(
      (failure) {
        logger.error('Error al refrescar plantas: ${failure.message}');
        // Mantener el estado actual si falla el refresh
        if (currentState is _Loaded) {
          emit(currentState);
        } else {
          emit(PlantsState.error(failure.message));
        }
      },
      (plants) {
        logger.info('Plantas refrescadas: ${plants.length}');
        emit(PlantsState.loaded(plants));
      },
    );
  }
}
