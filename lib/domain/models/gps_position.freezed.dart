// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gps_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GpsPosition _$GpsPositionFromJson(Map<String, dynamic> json) {
  return _GpsPosition.fromJson(json);
}

/// @nodoc
mixin _$GpsPosition {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double? get altitude => throw _privateConstructorUsedError;
  double? get speed => throw _privateConstructorUsedError;
  double? get heading => throw _privateConstructorUsedError;
  double? get accuracy => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get hasFix => throw _privateConstructorUsedError;
  double? get verticalAccuracy => throw _privateConstructorUsedError;
  double? get headingAccuracy => throw _privateConstructorUsedError;

  /// Serializes this GpsPosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GpsPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GpsPositionCopyWith<GpsPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GpsPositionCopyWith<$Res> {
  factory $GpsPositionCopyWith(
    GpsPosition value,
    $Res Function(GpsPosition) then,
  ) = _$GpsPositionCopyWithImpl<$Res, GpsPosition>;
  @useResult
  $Res call({
    double latitude,
    double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    DateTime timestamp,
    bool hasFix,
    double? verticalAccuracy,
    double? headingAccuracy,
  });
}

/// @nodoc
class _$GpsPositionCopyWithImpl<$Res, $Val extends GpsPosition>
    implements $GpsPositionCopyWith<$Res> {
  _$GpsPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GpsPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? altitude = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? accuracy = freezed,
    Object? timestamp = null,
    Object? hasFix = null,
    Object? verticalAccuracy = freezed,
    Object? headingAccuracy = freezed,
  }) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            altitude: freezed == altitude
                ? _value.altitude
                : altitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            speed: freezed == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as double?,
            heading: freezed == heading
                ? _value.heading
                : heading // ignore: cast_nullable_to_non_nullable
                      as double?,
            accuracy: freezed == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            hasFix: null == hasFix
                ? _value.hasFix
                : hasFix // ignore: cast_nullable_to_non_nullable
                      as bool,
            verticalAccuracy: freezed == verticalAccuracy
                ? _value.verticalAccuracy
                : verticalAccuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            headingAccuracy: freezed == headingAccuracy
                ? _value.headingAccuracy
                : headingAccuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GpsPositionImplCopyWith<$Res>
    implements $GpsPositionCopyWith<$Res> {
  factory _$$GpsPositionImplCopyWith(
    _$GpsPositionImpl value,
    $Res Function(_$GpsPositionImpl) then,
  ) = __$$GpsPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double latitude,
    double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    DateTime timestamp,
    bool hasFix,
    double? verticalAccuracy,
    double? headingAccuracy,
  });
}

/// @nodoc
class __$$GpsPositionImplCopyWithImpl<$Res>
    extends _$GpsPositionCopyWithImpl<$Res, _$GpsPositionImpl>
    implements _$$GpsPositionImplCopyWith<$Res> {
  __$$GpsPositionImplCopyWithImpl(
    _$GpsPositionImpl _value,
    $Res Function(_$GpsPositionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GpsPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? altitude = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? accuracy = freezed,
    Object? timestamp = null,
    Object? hasFix = null,
    Object? verticalAccuracy = freezed,
    Object? headingAccuracy = freezed,
  }) {
    return _then(
      _$GpsPositionImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        altitude: freezed == altitude
            ? _value.altitude
            : altitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        speed: freezed == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as double?,
        heading: freezed == heading
            ? _value.heading
            : heading // ignore: cast_nullable_to_non_nullable
                  as double?,
        accuracy: freezed == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        hasFix: null == hasFix
            ? _value.hasFix
            : hasFix // ignore: cast_nullable_to_non_nullable
                  as bool,
        verticalAccuracy: freezed == verticalAccuracy
            ? _value.verticalAccuracy
            : verticalAccuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        headingAccuracy: freezed == headingAccuracy
            ? _value.headingAccuracy
            : headingAccuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GpsPositionImpl implements _GpsPosition {
  const _$GpsPositionImpl({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.timestamp,
    required this.hasFix,
    this.verticalAccuracy,
    this.headingAccuracy,
  });

  factory _$GpsPositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GpsPositionImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double? altitude;
  @override
  final double? speed;
  @override
  final double? heading;
  @override
  final double? accuracy;
  @override
  final DateTime timestamp;
  @override
  final bool hasFix;
  @override
  final double? verticalAccuracy;
  @override
  final double? headingAccuracy;

  @override
  String toString() {
    return 'GpsPosition(latitude: $latitude, longitude: $longitude, altitude: $altitude, speed: $speed, heading: $heading, accuracy: $accuracy, timestamp: $timestamp, hasFix: $hasFix, verticalAccuracy: $verticalAccuracy, headingAccuracy: $headingAccuracy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GpsPositionImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.hasFix, hasFix) || other.hasFix == hasFix) &&
            (identical(other.verticalAccuracy, verticalAccuracy) ||
                other.verticalAccuracy == verticalAccuracy) &&
            (identical(other.headingAccuracy, headingAccuracy) ||
                other.headingAccuracy == headingAccuracy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latitude,
    longitude,
    altitude,
    speed,
    heading,
    accuracy,
    timestamp,
    hasFix,
    verticalAccuracy,
    headingAccuracy,
  );

  /// Create a copy of GpsPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GpsPositionImplCopyWith<_$GpsPositionImpl> get copyWith =>
      __$$GpsPositionImplCopyWithImpl<_$GpsPositionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GpsPositionImplToJson(this);
  }
}

abstract class _GpsPosition implements GpsPosition {
  const factory _GpsPosition({
    required final double latitude,
    required final double longitude,
    final double? altitude,
    final double? speed,
    final double? heading,
    final double? accuracy,
    required final DateTime timestamp,
    required final bool hasFix,
    final double? verticalAccuracy,
    final double? headingAccuracy,
  }) = _$GpsPositionImpl;

  factory _GpsPosition.fromJson(Map<String, dynamic> json) =
      _$GpsPositionImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  double? get altitude;
  @override
  double? get speed;
  @override
  double? get heading;
  @override
  double? get accuracy;
  @override
  DateTime get timestamp;
  @override
  bool get hasFix;
  @override
  double? get verticalAccuracy;
  @override
  double? get headingAccuracy;

  /// Create a copy of GpsPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GpsPositionImplCopyWith<_$GpsPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
