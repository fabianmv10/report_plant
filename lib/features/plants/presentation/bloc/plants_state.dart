part of 'plants_bloc.dart';

@freezed
class PlantsState with _$PlantsState {
  const factory PlantsState.initial() = _Initial;
  const factory PlantsState.loading() = _Loading;
  const factory PlantsState.loaded(List<Plant> plants) = _Loaded;
  const factory PlantsState.error(String message) = _Error;
}
