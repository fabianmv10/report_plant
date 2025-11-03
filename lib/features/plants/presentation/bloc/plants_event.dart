part of 'plants_bloc.dart';

@freezed
class PlantsEvent with _$PlantsEvent {
  const factory PlantsEvent.loadPlants() = _LoadPlants;
  const factory PlantsEvent.refreshPlants() = _RefreshPlants;
}
