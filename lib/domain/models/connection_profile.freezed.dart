// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConnectionProfile _$ConnectionProfileFromJson(Map<String, dynamic> json) {
  return _ConnectionProfile.fromJson(json);
}

/// @nodoc
mixin _$ConnectionProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get connectionMethodIndex => throw _privateConstructorUsedError;
  String get targetIpAddress => throw _privateConstructorUsedError;
  int get targetPort => throw _privateConstructorUsedError;
  String get multicastGroupAddress => throw _privateConstructorUsedError;
  int get socketPort => throw _privateConstructorUsedError;
  int get websocketPort => throw _privateConstructorUsedError;
  String? get websocketUrl => throw _privateConstructorUsedError;
  String get taipDeviceId => throw _privateConstructorUsedError;

  /// Serializes this ConnectionProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionProfileCopyWith<ConnectionProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionProfileCopyWith<$Res> {
  factory $ConnectionProfileCopyWith(
    ConnectionProfile value,
    $Res Function(ConnectionProfile) then,
  ) = _$ConnectionProfileCopyWithImpl<$Res, ConnectionProfile>;
  @useResult
  $Res call({
    String id,
    String name,
    int connectionMethodIndex,
    String targetIpAddress,
    int targetPort,
    String multicastGroupAddress,
    int socketPort,
    int websocketPort,
    String? websocketUrl,
    String taipDeviceId,
  });
}

/// @nodoc
class _$ConnectionProfileCopyWithImpl<$Res, $Val extends ConnectionProfile>
    implements $ConnectionProfileCopyWith<$Res> {
  _$ConnectionProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? connectionMethodIndex = null,
    Object? targetIpAddress = null,
    Object? targetPort = null,
    Object? multicastGroupAddress = null,
    Object? socketPort = null,
    Object? websocketPort = null,
    Object? websocketUrl = freezed,
    Object? taipDeviceId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            connectionMethodIndex: null == connectionMethodIndex
                ? _value.connectionMethodIndex
                : connectionMethodIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            targetIpAddress: null == targetIpAddress
                ? _value.targetIpAddress
                : targetIpAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            targetPort: null == targetPort
                ? _value.targetPort
                : targetPort // ignore: cast_nullable_to_non_nullable
                      as int,
            multicastGroupAddress: null == multicastGroupAddress
                ? _value.multicastGroupAddress
                : multicastGroupAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            socketPort: null == socketPort
                ? _value.socketPort
                : socketPort // ignore: cast_nullable_to_non_nullable
                      as int,
            websocketPort: null == websocketPort
                ? _value.websocketPort
                : websocketPort // ignore: cast_nullable_to_non_nullable
                      as int,
            websocketUrl: freezed == websocketUrl
                ? _value.websocketUrl
                : websocketUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            taipDeviceId: null == taipDeviceId
                ? _value.taipDeviceId
                : taipDeviceId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionProfileImplCopyWith<$Res>
    implements $ConnectionProfileCopyWith<$Res> {
  factory _$$ConnectionProfileImplCopyWith(
    _$ConnectionProfileImpl value,
    $Res Function(_$ConnectionProfileImpl) then,
  ) = __$$ConnectionProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int connectionMethodIndex,
    String targetIpAddress,
    int targetPort,
    String multicastGroupAddress,
    int socketPort,
    int websocketPort,
    String? websocketUrl,
    String taipDeviceId,
  });
}

/// @nodoc
class __$$ConnectionProfileImplCopyWithImpl<$Res>
    extends _$ConnectionProfileCopyWithImpl<$Res, _$ConnectionProfileImpl>
    implements _$$ConnectionProfileImplCopyWith<$Res> {
  __$$ConnectionProfileImplCopyWithImpl(
    _$ConnectionProfileImpl _value,
    $Res Function(_$ConnectionProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? connectionMethodIndex = null,
    Object? targetIpAddress = null,
    Object? targetPort = null,
    Object? multicastGroupAddress = null,
    Object? socketPort = null,
    Object? websocketPort = null,
    Object? websocketUrl = freezed,
    Object? taipDeviceId = null,
  }) {
    return _then(
      _$ConnectionProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        connectionMethodIndex: null == connectionMethodIndex
            ? _value.connectionMethodIndex
            : connectionMethodIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        targetIpAddress: null == targetIpAddress
            ? _value.targetIpAddress
            : targetIpAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        targetPort: null == targetPort
            ? _value.targetPort
            : targetPort // ignore: cast_nullable_to_non_nullable
                  as int,
        multicastGroupAddress: null == multicastGroupAddress
            ? _value.multicastGroupAddress
            : multicastGroupAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        socketPort: null == socketPort
            ? _value.socketPort
            : socketPort // ignore: cast_nullable_to_non_nullable
                  as int,
        websocketPort: null == websocketPort
            ? _value.websocketPort
            : websocketPort // ignore: cast_nullable_to_non_nullable
                  as int,
        websocketUrl: freezed == websocketUrl
            ? _value.websocketUrl
            : websocketUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        taipDeviceId: null == taipDeviceId
            ? _value.taipDeviceId
            : taipDeviceId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionProfileImpl implements _ConnectionProfile {
  const _$ConnectionProfileImpl({
    required this.id,
    required this.name,
    required this.connectionMethodIndex,
    required this.targetIpAddress,
    required this.targetPort,
    required this.multicastGroupAddress,
    required this.socketPort,
    required this.websocketPort,
    this.websocketUrl,
    required this.taipDeviceId,
  });

  factory _$ConnectionProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int connectionMethodIndex;
  @override
  final String targetIpAddress;
  @override
  final int targetPort;
  @override
  final String multicastGroupAddress;
  @override
  final int socketPort;
  @override
  final int websocketPort;
  @override
  final String? websocketUrl;
  @override
  final String taipDeviceId;

  @override
  String toString() {
    return 'ConnectionProfile(id: $id, name: $name, connectionMethodIndex: $connectionMethodIndex, targetIpAddress: $targetIpAddress, targetPort: $targetPort, multicastGroupAddress: $multicastGroupAddress, socketPort: $socketPort, websocketPort: $websocketPort, websocketUrl: $websocketUrl, taipDeviceId: $taipDeviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.connectionMethodIndex, connectionMethodIndex) ||
                other.connectionMethodIndex == connectionMethodIndex) &&
            (identical(other.targetIpAddress, targetIpAddress) ||
                other.targetIpAddress == targetIpAddress) &&
            (identical(other.targetPort, targetPort) ||
                other.targetPort == targetPort) &&
            (identical(other.multicastGroupAddress, multicastGroupAddress) ||
                other.multicastGroupAddress == multicastGroupAddress) &&
            (identical(other.socketPort, socketPort) ||
                other.socketPort == socketPort) &&
            (identical(other.websocketPort, websocketPort) ||
                other.websocketPort == websocketPort) &&
            (identical(other.websocketUrl, websocketUrl) ||
                other.websocketUrl == websocketUrl) &&
            (identical(other.taipDeviceId, taipDeviceId) ||
                other.taipDeviceId == taipDeviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    connectionMethodIndex,
    targetIpAddress,
    targetPort,
    multicastGroupAddress,
    socketPort,
    websocketPort,
    websocketUrl,
    taipDeviceId,
  );

  /// Create a copy of ConnectionProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionProfileImplCopyWith<_$ConnectionProfileImpl> get copyWith =>
      __$$ConnectionProfileImplCopyWithImpl<_$ConnectionProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionProfileImplToJson(this);
  }
}

abstract class _ConnectionProfile implements ConnectionProfile {
  const factory _ConnectionProfile({
    required final String id,
    required final String name,
    required final int connectionMethodIndex,
    required final String targetIpAddress,
    required final int targetPort,
    required final String multicastGroupAddress,
    required final int socketPort,
    required final int websocketPort,
    final String? websocketUrl,
    required final String taipDeviceId,
  }) = _$ConnectionProfileImpl;

  factory _ConnectionProfile.fromJson(Map<String, dynamic> json) =
      _$ConnectionProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get connectionMethodIndex;
  @override
  String get targetIpAddress;
  @override
  int get targetPort;
  @override
  String get multicastGroupAddress;
  @override
  int get socketPort;
  @override
  int get websocketPort;
  @override
  String? get websocketUrl;
  @override
  String get taipDeviceId;

  /// Create a copy of ConnectionProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionProfileImplCopyWith<_$ConnectionProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
