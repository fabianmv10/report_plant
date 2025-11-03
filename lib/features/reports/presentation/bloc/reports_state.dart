part of 'reports_bloc.dart';

@freezed
class ReportsState with _$ReportsState {
  const factory ReportsState.initial() = _Initial;
  const factory ReportsState.loading() = _Loading;
  const factory ReportsState.syncing() = _Syncing;
  const factory ReportsState.loaded(
    List<Report> reports, {
    @Default(false) bool hasReachedMax,
    String? filteredByPlant,
  }) = _Loaded;
  const factory ReportsState.error(String message) = _Error;
}
