// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConnectionStatus _$ConnectionStatusFromJson(Map<String, dynamic> json) {
  return _ConnectionStatus.fromJson(json);
}

/// @nodoc
mixin _$ConnectionStatus {
  bool get isActive => throw _privateConstructorUsedError;
  bool get isConnected => throw _privateConstructorUsedError;
  int get connectedClientCount => throw _privateConstructorUsedError;
  int get totalTxCount => throw _privateConstructorUsedError;
  int get totalRxCount => throw _privateConstructorUsedError;
  String? get localIpAddress => throw _privateConstructorUsedError;
  String? get bleStatus => throw _privateConstructorUsedError;
  DateTime? get lastTxTime => throw _privateConstructorUsedError;
  String? get activeProtocol => throw _privateConstructorUsedError;

  /// Serializes this ConnectionStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionStatusCopyWith<ConnectionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStatusCopyWith<$Res> {
  factory $ConnectionStatusCopyWith(
    ConnectionStatus value,
    $Res Function(ConnectionStatus) then,
  ) = _$ConnectionStatusCopyWithImpl<$Res, ConnectionStatus>;
  @useResult
  $Res call({
    bool isActive,
    bool isConnected,
    int connectedClientCount,
    int totalTxCount,
    int totalRxCount,
    String? localIpAddress,
    String? bleStatus,
    DateTime? lastTxTime,
    String? activeProtocol,
  });
}

/// @nodoc
class _$ConnectionStatusCopyWithImpl<$Res, $Val extends ConnectionStatus>
    implements $ConnectionStatusCopyWith<$Res> {
  _$ConnectionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? isConnected = null,
    Object? connectedClientCount = null,
    Object? totalTxCount = null,
    Object? totalRxCount = null,
    Object? localIpAddress = freezed,
    Object? bleStatus = freezed,
    Object? lastTxTime = freezed,
    Object? activeProtocol = freezed,
  }) {
    return _then(
      _value.copyWith(
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isConnected: null == isConnected
                ? _value.isConnected
                : isConnected // ignore: cast_nullable_to_non_nullable
                      as bool,
            connectedClientCount: null == connectedClientCount
                ? _value.connectedClientCount
                : connectedClientCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalTxCount: null == totalTxCount
                ? _value.totalTxCount
                : totalTxCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRxCount: null == totalRxCount
                ? _value.totalRxCount
                : totalRxCount // ignore: cast_nullable_to_non_nullable
                      as int,
            localIpAddress: freezed == localIpAddress
                ? _value.localIpAddress
                : localIpAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            bleStatus: freezed == bleStatus
                ? _value.bleStatus
                : bleStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastTxTime: freezed == lastTxTime
                ? _value.lastTxTime
                : lastTxTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            activeProtocol: freezed == activeProtocol
                ? _value.activeProtocol
                : activeProtocol // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionStatusImplCopyWith<$Res>
    implements $ConnectionStatusCopyWith<$Res> {
  factory _$$ConnectionStatusImplCopyWith(
    _$ConnectionStatusImpl value,
    $Res Function(_$ConnectionStatusImpl) then,
  ) = __$$ConnectionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isActive,
    bool isConnected,
    int connectedClientCount,
    int totalTxCount,
    int totalRxCount,
    String? localIpAddress,
    String? bleStatus,
    DateTime? lastTxTime,
    String? activeProtocol,
  });
}

/// @nodoc
class __$$ConnectionStatusImplCopyWithImpl<$Res>
    extends _$ConnectionStatusCopyWithImpl<$Res, _$ConnectionStatusImpl>
    implements _$$ConnectionStatusImplCopyWith<$Res> {
  __$$ConnectionStatusImplCopyWithImpl(
    _$ConnectionStatusImpl _value,
    $Res Function(_$ConnectionStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? isConnected = null,
    Object? connectedClientCount = null,
    Object? totalTxCount = null,
    Object? totalRxCount = null,
    Object? localIpAddress = freezed,
    Object? bleStatus = freezed,
    Object? lastTxTime = freezed,
    Object? activeProtocol = freezed,
  }) {
    return _then(
      _$ConnectionStatusImpl(
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isConnected: null == isConnected
            ? _value.isConnected
            : isConnected // ignore: cast_nullable_to_non_nullable
                  as bool,
        connectedClientCount: null == connectedClientCount
            ? _value.connectedClientCount
            : connectedClientCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalTxCount: null == totalTxCount
            ? _value.totalTxCount
            : totalTxCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRxCount: null == totalRxCount
            ? _value.totalRxCount
            : totalRxCount // ignore: cast_nullable_to_non_nullable
                  as int,
        localIpAddress: freezed == localIpAddress
            ? _value.localIpAddress
            : localIpAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        bleStatus: freezed == bleStatus
            ? _value.bleStatus
            : bleStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastTxTime: freezed == lastTxTime
            ? _value.lastTxTime
            : lastTxTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        activeProtocol: freezed == activeProtocol
            ? _value.activeProtocol
            : activeProtocol // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionStatusImpl implements _ConnectionStatus {
  const _$ConnectionStatusImpl({
    required this.isActive,
    required this.isConnected,
    required this.connectedClientCount,
    required this.totalTxCount,
    required this.totalRxCount,
    this.localIpAddress,
    this.bleStatus,
    this.lastTxTime,
    this.activeProtocol,
  });

  factory _$ConnectionStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionStatusImplFromJson(json);

  @override
  final bool isActive;
  @override
  final bool isConnected;
  @override
  final int connectedClientCount;
  @override
  final int totalTxCount;
  @override
  final int totalRxCount;
  @override
  final String? localIpAddress;
  @override
  final String? bleStatus;
  @override
  final DateTime? lastTxTime;
  @override
  final String? activeProtocol;

  @override
  String toString() {
    return 'ConnectionStatus(isActive: $isActive, isConnected: $isConnected, connectedClientCount: $connectedClientCount, totalTxCount: $totalTxCount, totalRxCount: $totalRxCount, localIpAddress: $localIpAddress, bleStatus: $bleStatus, lastTxTime: $lastTxTime, activeProtocol: $activeProtocol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStatusImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.connectedClientCount, connectedClientCount) ||
                other.connectedClientCount == connectedClientCount) &&
            (identical(other.totalTxCount, totalTxCount) ||
                other.totalTxCount == totalTxCount) &&
            (identical(other.totalRxCount, totalRxCount) ||
                other.totalRxCount == totalRxCount) &&
            (identical(other.localIpAddress, localIpAddress) ||
                other.localIpAddress == localIpAddress) &&
            (identical(other.bleStatus, bleStatus) ||
                other.bleStatus == bleStatus) &&
            (identical(other.lastTxTime, lastTxTime) ||
                other.lastTxTime == lastTxTime) &&
            (identical(other.activeProtocol, activeProtocol) ||
                other.activeProtocol == activeProtocol));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isActive,
    isConnected,
    connectedClientCount,
    totalTxCount,
    totalRxCount,
    localIpAddress,
    bleStatus,
    lastTxTime,
    activeProtocol,
  );

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStatusImplCopyWith<_$ConnectionStatusImpl> get copyWith =>
      __$$ConnectionStatusImplCopyWithImpl<_$ConnectionStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionStatusImplToJson(this);
  }
}

abstract class _ConnectionStatus implements ConnectionStatus {
  const factory _ConnectionStatus({
    required final bool isActive,
    required final bool isConnected,
    required final int connectedClientCount,
    required final int totalTxCount,
    required final int totalRxCount,
    final String? localIpAddress,
    final String? bleStatus,
    final DateTime? lastTxTime,
    final String? activeProtocol,
  }) = _$ConnectionStatusImpl;

  factory _ConnectionStatus.fromJson(Map<String, dynamic> json) =
      _$ConnectionStatusImpl.fromJson;

  @override
  bool get isActive;
  @override
  bool get isConnected;
  @override
  int get connectedClientCount;
  @override
  int get totalTxCount;
  @override
  int get totalRxCount;
  @override
  String? get localIpAddress;
  @override
  String? get bleStatus;
  @override
  DateTime? get lastTxTime;
  @override
  String? get activeProtocol;

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionStatusImplCopyWith<_$ConnectionStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
