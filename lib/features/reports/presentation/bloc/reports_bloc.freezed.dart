// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reports_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReportsEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadReports,
    required TResult Function() loadMoreReports,
    required TResult Function() refreshReports,
    required TResult Function(String plantId) filterByPlant,
    required TResult Function() syncReports,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadReports,
    TResult? Function()? loadMoreReports,
    TResult? Function()? refreshReports,
    TResult? Function(String plantId)? filterByPlant,
    TResult? Function()? syncReports,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadReports,
    TResult Function()? loadMoreReports,
    TResult Function()? refreshReports,
    TResult Function(String plantId)? filterByPlant,
    TResult Function()? syncReports,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadReports value) loadReports,
    required TResult Function(_LoadMoreReports value) loadMoreReports,
    required TResult Function(_RefreshReports value) refreshReports,
    required TResult Function(_FilterByPlant value) filterByPlant,
    required TResult Function(_SyncReports value) syncReports,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadReports value)? loadReports,
    TResult? Function(_LoadMoreReports value)? loadMoreReports,
    TResult? Function(_RefreshReports value)? refreshReports,
    TResult? Function(_FilterByPlant value)? filterByPlant,
    TResult? Function(_SyncReports value)? syncReports,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadReports value)? loadReports,
    TResult Function(_LoadMoreReports value)? loadMoreReports,
    TResult Function(_RefreshReports value)? refreshReports,
    TResult Function(_FilterByPlant value)? filterByPlant,
    TResult Function(_SyncReports value)? syncReports,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportsEventCopyWith<$Res> {
  factory $ReportsEventCopyWith(
          ReportsEvent value, $Res Function(ReportsEvent) then) =
      _$ReportsEventCopyWithImpl<$Res, ReportsEvent>;
}

/// @nodoc
class _$ReportsEventCopyWithImpl<$Res, $Val extends ReportsEvent>
    implements $ReportsEventCopyWith<$Res> {
  _$ReportsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadReportsImplCopyWith<$Res> {
  factory _$$LoadReportsImplCopyWith(
          _$LoadReportsImpl value, $Res Function(_$LoadReportsImpl) then) =
      __$$LoadReportsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadReportsImplCopyWithImpl<$Res>
    extends _$ReportsEventCopyWithImpl<$Res, _$LoadReportsImpl>
    implements _$$LoadReportsImplCopyWith<$Res> {
  __$$LoadReportsImplCopyWithImpl(
      _$LoadReportsImpl _value, $Res Function(_$LoadReportsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadReportsImpl implements _LoadReports {
  const _$LoadReportsImpl();

  @override
  String toString() {
    return 'ReportsEvent.loadReports()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadReportsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadReports,
    required TResult Function() loadMoreReports,
    required TResult Function() refreshReports,
    required TResult Function(String plantId) filterByPlant,
    required TResult Function() syncReports,
  }) {
    return loadReports();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadReports,
    TResult? Function()? loadMoreReports,
    TResult? Function()? refreshReports,
    TResult? Function(String plantId)? filterByPlant,
    TResult? Function()? syncReports,
  }) {
    return loadReports?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadReports,
    TResult Function()? loadMoreReports,
    TResult Function()? refreshReports,
    TResult Function(String plantId)? filterByPlant,
    TResult Function()? syncReports,
    required TResult orElse(),
  }) {
    if (loadReports != null) {
      return loadReports();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadReports value) loadReports,
    required TResult Function(_LoadMoreReports value) loadMoreReports,
    required TResult Function(_RefreshReports value) refreshReports,
    required TResult Function(_FilterByPlant value) filterByPlant,
    required TResult Function(_SyncReports value) syncReports,
  }) {
    return loadReports(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadReports value)? loadReports,
    TResult? Function(_LoadMoreReports value)? loadMoreReports,
    TResult? Function(_RefreshReports value)? refreshReports,
    TResult? Function(_FilterByPlant value)? filterByPlant,
    TResult? Function(_SyncReports value)? syncReports,
  }) {
    return loadReports?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadReports value)? loadReports,
    TResult Function(_LoadMoreReports value)? loadMoreReports,
    TResult Function(_RefreshReports value)? refreshReports,
    TResult Function(_FilterByPlant value)? filterByPlant,
    TResult Function(_SyncReports value)? syncReports,
    required TResult orElse(),
  }) {
    if (loadReports != null) {
      return loadReports(this);
    }
    return orElse();
  }
}

abstract class _LoadReports implements ReportsEvent {
  const factory _LoadReports() = _$LoadReportsImpl;
}

/// @nodoc
abstract class _$$LoadMoreReportsImplCopyWith<$Res> {
  factory _$$LoadMoreReportsImplCopyWith(_$LoadMoreReportsImpl value,
          $Res Function(_$LoadMoreReportsImpl) then) =
      __$$LoadMoreReportsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadMoreReportsImplCopyWithImpl<$Res>
    extends _$ReportsEventCopyWithImpl<$Res, _$LoadMoreReportsImpl>
    implements _$$LoadMoreReportsImplCopyWith<$Res> {
  __$$LoadMoreReportsImplCopyWithImpl(
      _$LoadMoreReportsImpl _value, $Res Function(_$LoadMoreReportsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadMoreReportsImpl implements _LoadMoreReports {
  const _$LoadMoreReportsImpl();

  @override
  String toString() {
    return 'ReportsEvent.loadMoreReports()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadMoreReportsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadReports,
    required TResult Function() loadMoreReports,
    required TResult Function() refreshReports,
    required TResult Function(String plantId) filterByPlant,
    required TResult Function() syncReports,
  }) {
    return loadMoreReports();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadReports,
    TResult? Function()? loadMoreReports,
    TResult? Function()? refreshReports,
    TResult? Function(String plantId)? filterByPlant,
    TResult? Function()? syncReports,
  }) {
    return loadMoreReports?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadReports,
    TResult Function()? loadMoreReports,
    TResult Function()? refreshReports,
    TResult Function(String plantId)? filterByPlant,
    TResult Function()? syncReports,
    required TResult orElse(),
  }) {
    if (loadMoreReports != null) {
      return loadMoreReports();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadReports value) loadReports,
    required TResult Function(_LoadMoreReports value) loadMoreReports,
    required TResult Function(_RefreshReports value) refreshReports,
    required TResult Function(_FilterByPlant value) filterByPlant,
    required TResult Function(_SyncReports value) syncReports,
  }) {
    return loadMoreReports(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadReports value)? loadReports,
    TResult? Function(_LoadMoreReports value)? loadMoreReports,
    TResult? Function(_RefreshReports value)? refreshReports,
    TResult? Function(_FilterByPlant value)? filterByPlant,
    TResult? Function(_SyncReports value)? syncReports,
  }) {
    return loadMoreReports?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadReports value)? loadReports,
    TResult Function(_LoadMoreReports value)? loadMoreReports,
    TResult Function(_RefreshReports value)? refreshReports,
    TResult Function(_FilterByPlant value)? filterByPlant,
    TResult Function(_SyncReports value)? syncReports,
    required TResult orElse(),
  }) {
    if (loadMoreReports != null) {
      return loadMoreReports(this);
    }
    return orElse();
  }
}

abstract class _LoadMoreReports implements ReportsEvent {
  const factory _LoadMoreReports() = _$LoadMoreReportsImpl;
}

/// @nodoc
abstract class _$$RefreshReportsImplCopyWith<$Res> {
  factory _$$RefreshReportsImplCopyWith(_$RefreshReportsImpl value,
          $Res Function(_$RefreshReportsImpl) then) =
      __$$RefreshReportsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshReportsImplCopyWithImpl<$Res>
    extends _$ReportsEventCopyWithImpl<$Res, _$RefreshReportsImpl>
    implements _$$RefreshReportsImplCopyWith<$Res> {
  __$$RefreshReportsImplCopyWithImpl(
      _$RefreshReportsImpl _value, $Res Function(_$RefreshReportsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RefreshReportsImpl implements _RefreshReports {
  const _$RefreshReportsImpl();

  @override
  String toString() {
    return 'ReportsEvent.refreshReports()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RefreshReportsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadReports,
    required TResult Function() loadMoreReports,
    required TResult Function() refreshReports,
    required TResult Function(String plantId) filterByPlant,
    required TResult Function() syncReports,
  }) {
    return refreshReports();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadReports,
    TResult? Function()? loadMoreReports,
    TResult? Function()? refreshReports,
    TResult? Function(String plantId)? filterByPlant,
    TResult? Function()? syncReports,
  }) {
    return refreshReports?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadReports,
    TResult Function()? loadMoreReports,
    TResult Function()? refreshReports,
    TResult Function(String plantId)? filterByPlant,
    TResult Function()? syncReports,
    required TResult orElse(),
  }) {
    if (refreshReports != null) {
      return refreshReports();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadReports value) loadReports,
    required TResult Function(_LoadMoreReports value) loadMoreReports,
    required TResult Function(_RefreshReports value) refreshReports,
    required TResult Function(_FilterByPlant value) filterByPlant,
    required TResult Function(_SyncReports value) syncReports,
  }) {
    return refreshReports(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadReports value)? loadReports,
    TResult? Function(_LoadMoreReports value)? loadMoreReports,
    TResult? Function(_RefreshReports value)? refreshReports,
    TResult? Function(_FilterByPlant value)? filterByPlant,
    TResult? Function(_SyncReports value)? syncReports,
  }) {
    return refreshReports?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadReports value)? loadReports,
    TResult Function(_LoadMoreReports value)? loadMoreReports,
    TResult Function(_RefreshReports value)? refreshReports,
    TResult Function(_FilterByPlant value)? filterByPlant,
    TResult Function(_SyncReports value)? syncReports,
    required TResult orElse(),
  }) {
    if (refreshReports != null) {
      return refreshReports(this);
    }
    return orElse();
  }
}

abstract class _RefreshReports implements ReportsEvent {
  const factory _RefreshReports() = _$RefreshReportsImpl;
}

/// @nodoc
abstract class _$$FilterByPlantImplCopyWith<$Res> {
  factory _$$FilterByPlantImplCopyWith(
          _$FilterByPlantImpl value, $Res Function(_$FilterByPlantImpl) then) =
      __$$FilterByPlantImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String plantId});
}

/// @nodoc
class __$$FilterByPlantImplCopyWithImpl<$Res>
    extends _$ReportsEventCopyWithImpl<$Res, _$FilterByPlantImpl>
    implements _$$FilterByPlantImplCopyWith<$Res> {
  __$$FilterByPlantImplCopyWithImpl(
      _$FilterByPlantImpl _value, $Res Function(_$FilterByPlantImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plantId = null,
  }) {
    return _then(_$FilterByPlantImpl(
      null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FilterByPlantImpl implements _FilterByPlant {
  const _$FilterByPlantImpl(this.plantId);

  @override
  final String plantId;

  @override
  String toString() {
    return 'ReportsEvent.filterByPlant(plantId: $plantId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterByPlantImpl &&
            (identical(other.plantId, plantId) || other.plantId == plantId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, plantId);

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterByPlantImplCopyWith<_$FilterByPlantImpl> get copyWith =>
      __$$FilterByPlantImplCopyWithImpl<_$FilterByPlantImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadReports,
    required TResult Function() loadMoreReports,
    required TResult Function() refreshReports,
    required TResult Function(String plantId) filterByPlant,
    required TResult Function() syncReports,
  }) {
    return filterByPlant(plantId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadReports,
    TResult? Function()? loadMoreReports,
    TResult? Function()? refreshReports,
    TResult? Function(String plantId)? filterByPlant,
    TResult? Function()? syncReports,
  }) {
    return filterByPlant?.call(plantId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadReports,
    TResult Function()? loadMoreReports,
    TResult Function()? refreshReports,
    TResult Function(String plantId)? filterByPlant,
    TResult Function()? syncReports,
    required TResult orElse(),
  }) {
    if (filterByPlant != null) {
      return filterByPlant(plantId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadReports value) loadReports,
    required TResult Function(_LoadMoreReports value) loadMoreReports,
    required TResult Function(_RefreshReports value) refreshReports,
    required TResult Function(_FilterByPlant value) filterByPlant,
    required TResult Function(_SyncReports value) syncReports,
  }) {
    return filterByPlant(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadReports value)? loadReports,
    TResult? Function(_LoadMoreReports value)? loadMoreReports,
    TResult? Function(_RefreshReports value)? refreshReports,
    TResult? Function(_FilterByPlant value)? filterByPlant,
    TResult? Function(_SyncReports value)? syncReports,
  }) {
    return filterByPlant?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadReports value)? loadReports,
    TResult Function(_LoadMoreReports value)? loadMoreReports,
    TResult Function(_RefreshReports value)? refreshReports,
    TResult Function(_FilterByPlant value)? filterByPlant,
    TResult Function(_SyncReports value)? syncReports,
    required TResult orElse(),
  }) {
    if (filterByPlant != null) {
      return filterByPlant(this);
    }
    return orElse();
  }
}

abstract class _FilterByPlant implements ReportsEvent {
  const factory _FilterByPlant(final String plantId) = _$FilterByPlantImpl;

  String get plantId;

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterByPlantImplCopyWith<_$FilterByPlantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncReportsImplCopyWith<$Res> {
  factory _$$SyncReportsImplCopyWith(
          _$SyncReportsImpl value, $Res Function(_$SyncReportsImpl) then) =
      __$$SyncReportsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncReportsImplCopyWithImpl<$Res>
    extends _$ReportsEventCopyWithImpl<$Res, _$SyncReportsImpl>
    implements _$$SyncReportsImplCopyWith<$Res> {
  __$$SyncReportsImplCopyWithImpl(
      _$SyncReportsImpl _value, $Res Function(_$SyncReportsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SyncReportsImpl implements _SyncReports {
  const _$SyncReportsImpl();

  @override
  String toString() {
    return 'ReportsEvent.syncReports()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncReportsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadReports,
    required TResult Function() loadMoreReports,
    required TResult Function() refreshReports,
    required TResult Function(String plantId) filterByPlant,
    required TResult Function() syncReports,
  }) {
    return syncReports();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadReports,
    TResult? Function()? loadMoreReports,
    TResult? Function()? refreshReports,
    TResult? Function(String plantId)? filterByPlant,
    TResult? Function()? syncReports,
  }) {
    return syncReports?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadReports,
    TResult Function()? loadMoreReports,
    TResult Function()? refreshReports,
    TResult Function(String plantId)? filterByPlant,
    TResult Function()? syncReports,
    required TResult orElse(),
  }) {
    if (syncReports != null) {
      return syncReports();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadReports value) loadReports,
    required TResult Function(_LoadMoreReports value) loadMoreReports,
    required TResult Function(_RefreshReports value) refreshReports,
    required TResult Function(_FilterByPlant value) filterByPlant,
    required TResult Function(_SyncReports value) syncReports,
  }) {
    return syncReports(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadReports value)? loadReports,
    TResult? Function(_LoadMoreReports value)? loadMoreReports,
    TResult? Function(_RefreshReports value)? refreshReports,
    TResult? Function(_FilterByPlant value)? filterByPlant,
    TResult? Function(_SyncReports value)? syncReports,
  }) {
    return syncReports?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadReports value)? loadReports,
    TResult Function(_LoadMoreReports value)? loadMoreReports,
    TResult Function(_RefreshReports value)? refreshReports,
    TResult Function(_FilterByPlant value)? filterByPlant,
    TResult Function(_SyncReports value)? syncReports,
    required TResult orElse(),
  }) {
    if (syncReports != null) {
      return syncReports(this);
    }
    return orElse();
  }
}

abstract class _SyncReports implements ReportsEvent {
  const factory _SyncReports() = _$SyncReportsImpl;
}

/// @nodoc
mixin _$ReportsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() syncing,
    required TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? syncing,
    TResult? Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? syncing,
    TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportsStateCopyWith<$Res> {
  factory $ReportsStateCopyWith(
          ReportsState value, $Res Function(ReportsState) then) =
      _$ReportsStateCopyWithImpl<$Res, ReportsState>;
}

/// @nodoc
class _$ReportsStateCopyWithImpl<$Res, $Val extends ReportsState>
    implements $ReportsStateCopyWith<$Res> {
  _$ReportsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ReportsStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ReportsState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() syncing,
    required TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? syncing,
    TResult? Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? syncing,
    TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ReportsState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ReportsStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ReportsState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() syncing,
    required TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? syncing,
    TResult? Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? syncing,
    TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ReportsState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$SyncingImplCopyWith<$Res> {
  factory _$$SyncingImplCopyWith(
          _$SyncingImpl value, $Res Function(_$SyncingImpl) then) =
      __$$SyncingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncingImplCopyWithImpl<$Res>
    extends _$ReportsStateCopyWithImpl<$Res, _$SyncingImpl>
    implements _$$SyncingImplCopyWith<$Res> {
  __$$SyncingImplCopyWithImpl(
      _$SyncingImpl _value, $Res Function(_$SyncingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SyncingImpl implements _Syncing {
  const _$SyncingImpl();

  @override
  String toString() {
    return 'ReportsState.syncing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() syncing,
    required TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)
        loaded,
    required TResult Function(String message) error,
  }) {
    return syncing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? syncing,
    TResult? Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return syncing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? syncing,
    TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return syncing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return syncing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing(this);
    }
    return orElse();
  }
}

abstract class _Syncing implements ReportsState {
  const factory _Syncing() = _$SyncingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<Report> reports, bool hasReachedMax, String? filteredByPlant});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$ReportsStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reports = null,
    Object? hasReachedMax = null,
    Object? filteredByPlant = freezed,
  }) {
    return _then(_$LoadedImpl(
      null == reports
          ? _value._reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      hasReachedMax: null == hasReachedMax
          ? _value.hasReachedMax
          : hasReachedMax // ignore: cast_nullable_to_non_nullable
              as bool,
      filteredByPlant: freezed == filteredByPlant
          ? _value.filteredByPlant
          : filteredByPlant // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(final List<Report> reports,
      {this.hasReachedMax = false, this.filteredByPlant})
      : _reports = reports;

  final List<Report> _reports;
  @override
  List<Report> get reports {
    if (_reports is EqualUnmodifiableListView) return _reports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reports);
  }

  @override
  @JsonKey()
  final bool hasReachedMax;
  @override
  final String? filteredByPlant;

  @override
  String toString() {
    return 'ReportsState.loaded(reports: $reports, hasReachedMax: $hasReachedMax, filteredByPlant: $filteredByPlant)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._reports, _reports) &&
            (identical(other.hasReachedMax, hasReachedMax) ||
                other.hasReachedMax == hasReachedMax) &&
            (identical(other.filteredByPlant, filteredByPlant) ||
                other.filteredByPlant == filteredByPlant));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_reports),
      hasReachedMax,
      filteredByPlant);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() syncing,
    required TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(reports, hasReachedMax, filteredByPlant);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? syncing,
    TResult? Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(reports, hasReachedMax, filteredByPlant);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? syncing,
    TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(reports, hasReachedMax, filteredByPlant);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements ReportsState {
  const factory _Loaded(final List<Report> reports,
      {final bool hasReachedMax, final String? filteredByPlant}) = _$LoadedImpl;

  List<Report> get reports;
  bool get hasReachedMax;
  String? get filteredByPlant;

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$ReportsStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'ReportsState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() syncing,
    required TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? syncing,
    TResult? Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? syncing,
    TResult Function(
            List<Report> reports, bool hasReachedMax, String? filteredByPlant)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ReportsState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of ReportsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
