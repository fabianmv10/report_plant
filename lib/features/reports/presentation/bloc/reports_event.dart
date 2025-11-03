part of 'reports_bloc.dart';

@freezed
class ReportsEvent with _$ReportsEvent {
  const factory ReportsEvent.loadReports() = _LoadReports;
  const factory ReportsEvent.loadMoreReports() = _LoadMoreReports;
  const factory ReportsEvent.refreshReports() = _RefreshReports;
  const factory ReportsEvent.filterByPlant(String plantId) = _FilterByPlant;
  const factory ReportsEvent.syncReports() = _SyncReports;
}
