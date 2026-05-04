// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taip_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaipMessage _$TaipMessageFromJson(Map<String, dynamic> json) {
  return _TaipMessage.fromJson(json);
}

/// @nodoc
mixin _$TaipMessage {
  TaipMessageType get type => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  String get rawMessage => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this TaipMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaipMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaipMessageCopyWith<TaipMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaipMessageCopyWith<$Res> {
  factory $TaipMessageCopyWith(
    TaipMessage value,
    $Res Function(TaipMessage) then,
  ) = _$TaipMessageCopyWithImpl<$Res, TaipMessage>;
  @useResult
  $Res call({
    TaipMessageType type,
    String deviceId,
    String rawMessage,
    DateTime generatedAt,
  });
}

/// @nodoc
class _$TaipMessageCopyWithImpl<$Res, $Val extends TaipMessage>
    implements $TaipMessageCopyWith<$Res> {
  _$TaipMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaipMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? deviceId = null,
    Object? rawMessage = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TaipMessageType,
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            rawMessage: null == rawMessage
                ? _value.rawMessage
                : rawMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaipMessageImplCopyWith<$Res>
    implements $TaipMessageCopyWith<$Res> {
  factory _$$TaipMessageImplCopyWith(
    _$TaipMessageImpl value,
    $Res Function(_$TaipMessageImpl) then,
  ) = __$$TaipMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TaipMessageType type,
    String deviceId,
    String rawMessage,
    DateTime generatedAt,
  });
}

/// @nodoc
class __$$TaipMessageImplCopyWithImpl<$Res>
    extends _$TaipMessageCopyWithImpl<$Res, _$TaipMessageImpl>
    implements _$$TaipMessageImplCopyWith<$Res> {
  __$$TaipMessageImplCopyWithImpl(
    _$TaipMessageImpl _value,
    $Res Function(_$TaipMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaipMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? deviceId = null,
    Object? rawMessage = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _$TaipMessageImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TaipMessageType,
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        rawMessage: null == rawMessage
            ? _value.rawMessage
            : rawMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaipMessageImpl implements _TaipMessage {
  const _$TaipMessageImpl({
    required this.type,
    required this.deviceId,
    required this.rawMessage,
    required this.generatedAt,
  });

  factory _$TaipMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaipMessageImplFromJson(json);

  @override
  final TaipMessageType type;
  @override
  final String deviceId;
  @override
  final String rawMessage;
  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'TaipMessage(type: $type, deviceId: $deviceId, rawMessage: $rawMessage, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaipMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.rawMessage, rawMessage) ||
                other.rawMessage == rawMessage) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, deviceId, rawMessage, generatedAt);

  /// Create a copy of TaipMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaipMessageImplCopyWith<_$TaipMessageImpl> get copyWith =>
      __$$TaipMessageImplCopyWithImpl<_$TaipMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaipMessageImplToJson(this);
  }
}

abstract class _TaipMessage implements TaipMessage {
  const factory _TaipMessage({
    required final TaipMessageType type,
    required final String deviceId,
    required final String rawMessage,
    required final DateTime generatedAt,
  }) = _$TaipMessageImpl;

  factory _TaipMessage.fromJson(Map<String, dynamic> json) =
      _$TaipMessageImpl.fromJson;

  @override
  TaipMessageType get type;
  @override
  String get deviceId;
  @override
  String get rawMessage;
  @override
  DateTime get generatedAt;

  /// Create a copy of TaipMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaipMessageImplCopyWith<_$TaipMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
