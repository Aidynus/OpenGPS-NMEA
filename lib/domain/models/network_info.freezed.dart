// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) {
  return _NetworkInfo.fromJson(json);
}

/// @nodoc
mixin _$NetworkInfo {
  String? get wifiIp => throw _privateConstructorUsedError;
  String? get cellularIp => throw _privateConstructorUsedError;
  String? get hotspotIp => throw _privateConstructorUsedError;
  String? get hotspotSubnet => throw _privateConstructorUsedError;
  bool get isHotspotActive => throw _privateConstructorUsedError;

  /// Serializes this NetworkInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NetworkInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NetworkInfoCopyWith<NetworkInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkInfoCopyWith<$Res> {
  factory $NetworkInfoCopyWith(
    NetworkInfo value,
    $Res Function(NetworkInfo) then,
  ) = _$NetworkInfoCopyWithImpl<$Res, NetworkInfo>;
  @useResult
  $Res call({
    String? wifiIp,
    String? cellularIp,
    String? hotspotIp,
    String? hotspotSubnet,
    bool isHotspotActive,
  });
}

/// @nodoc
class _$NetworkInfoCopyWithImpl<$Res, $Val extends NetworkInfo>
    implements $NetworkInfoCopyWith<$Res> {
  _$NetworkInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NetworkInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wifiIp = freezed,
    Object? cellularIp = freezed,
    Object? hotspotIp = freezed,
    Object? hotspotSubnet = freezed,
    Object? isHotspotActive = null,
  }) {
    return _then(
      _value.copyWith(
            wifiIp: freezed == wifiIp
                ? _value.wifiIp
                : wifiIp // ignore: cast_nullable_to_non_nullable
                      as String?,
            cellularIp: freezed == cellularIp
                ? _value.cellularIp
                : cellularIp // ignore: cast_nullable_to_non_nullable
                      as String?,
            hotspotIp: freezed == hotspotIp
                ? _value.hotspotIp
                : hotspotIp // ignore: cast_nullable_to_non_nullable
                      as String?,
            hotspotSubnet: freezed == hotspotSubnet
                ? _value.hotspotSubnet
                : hotspotSubnet // ignore: cast_nullable_to_non_nullable
                      as String?,
            isHotspotActive: null == isHotspotActive
                ? _value.isHotspotActive
                : isHotspotActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkInfoImplCopyWith<$Res>
    implements $NetworkInfoCopyWith<$Res> {
  factory _$$NetworkInfoImplCopyWith(
    _$NetworkInfoImpl value,
    $Res Function(_$NetworkInfoImpl) then,
  ) = __$$NetworkInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? wifiIp,
    String? cellularIp,
    String? hotspotIp,
    String? hotspotSubnet,
    bool isHotspotActive,
  });
}

/// @nodoc
class __$$NetworkInfoImplCopyWithImpl<$Res>
    extends _$NetworkInfoCopyWithImpl<$Res, _$NetworkInfoImpl>
    implements _$$NetworkInfoImplCopyWith<$Res> {
  __$$NetworkInfoImplCopyWithImpl(
    _$NetworkInfoImpl _value,
    $Res Function(_$NetworkInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NetworkInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wifiIp = freezed,
    Object? cellularIp = freezed,
    Object? hotspotIp = freezed,
    Object? hotspotSubnet = freezed,
    Object? isHotspotActive = null,
  }) {
    return _then(
      _$NetworkInfoImpl(
        wifiIp: freezed == wifiIp
            ? _value.wifiIp
            : wifiIp // ignore: cast_nullable_to_non_nullable
                  as String?,
        cellularIp: freezed == cellularIp
            ? _value.cellularIp
            : cellularIp // ignore: cast_nullable_to_non_nullable
                  as String?,
        hotspotIp: freezed == hotspotIp
            ? _value.hotspotIp
            : hotspotIp // ignore: cast_nullable_to_non_nullable
                  as String?,
        hotspotSubnet: freezed == hotspotSubnet
            ? _value.hotspotSubnet
            : hotspotSubnet // ignore: cast_nullable_to_non_nullable
                  as String?,
        isHotspotActive: null == isHotspotActive
            ? _value.isHotspotActive
            : isHotspotActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkInfoImpl implements _NetworkInfo {
  const _$NetworkInfoImpl({
    this.wifiIp,
    this.cellularIp,
    this.hotspotIp,
    this.hotspotSubnet,
    required this.isHotspotActive,
  });

  factory _$NetworkInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkInfoImplFromJson(json);

  @override
  final String? wifiIp;
  @override
  final String? cellularIp;
  @override
  final String? hotspotIp;
  @override
  final String? hotspotSubnet;
  @override
  final bool isHotspotActive;

  @override
  String toString() {
    return 'NetworkInfo(wifiIp: $wifiIp, cellularIp: $cellularIp, hotspotIp: $hotspotIp, hotspotSubnet: $hotspotSubnet, isHotspotActive: $isHotspotActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkInfoImpl &&
            (identical(other.wifiIp, wifiIp) || other.wifiIp == wifiIp) &&
            (identical(other.cellularIp, cellularIp) ||
                other.cellularIp == cellularIp) &&
            (identical(other.hotspotIp, hotspotIp) ||
                other.hotspotIp == hotspotIp) &&
            (identical(other.hotspotSubnet, hotspotSubnet) ||
                other.hotspotSubnet == hotspotSubnet) &&
            (identical(other.isHotspotActive, isHotspotActive) ||
                other.isHotspotActive == isHotspotActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    wifiIp,
    cellularIp,
    hotspotIp,
    hotspotSubnet,
    isHotspotActive,
  );

  /// Create a copy of NetworkInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkInfoImplCopyWith<_$NetworkInfoImpl> get copyWith =>
      __$$NetworkInfoImplCopyWithImpl<_$NetworkInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NetworkInfoImplToJson(this);
  }
}

abstract class _NetworkInfo implements NetworkInfo {
  const factory _NetworkInfo({
    final String? wifiIp,
    final String? cellularIp,
    final String? hotspotIp,
    final String? hotspotSubnet,
    required final bool isHotspotActive,
  }) = _$NetworkInfoImpl;

  factory _NetworkInfo.fromJson(Map<String, dynamic> json) =
      _$NetworkInfoImpl.fromJson;

  @override
  String? get wifiIp;
  @override
  String? get cellularIp;
  @override
  String? get hotspotIp;
  @override
  String? get hotspotSubnet;
  @override
  bool get isHotspotActive;

  /// Create a copy of NetworkInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkInfoImplCopyWith<_$NetworkInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
