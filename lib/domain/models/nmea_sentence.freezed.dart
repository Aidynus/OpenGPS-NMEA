// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nmea_sentence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NmeaSentence _$NmeaSentenceFromJson(Map<String, dynamic> json) {
  return _NmeaSentence.fromJson(json);
}

/// @nodoc
mixin _$NmeaSentence {
  NmeaSentenceType get type => throw _privateConstructorUsedError;
  String get rawSentence => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this NmeaSentence to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NmeaSentence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NmeaSentenceCopyWith<NmeaSentence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NmeaSentenceCopyWith<$Res> {
  factory $NmeaSentenceCopyWith(
    NmeaSentence value,
    $Res Function(NmeaSentence) then,
  ) = _$NmeaSentenceCopyWithImpl<$Res, NmeaSentence>;
  @useResult
  $Res call({NmeaSentenceType type, String rawSentence, DateTime generatedAt});
}

/// @nodoc
class _$NmeaSentenceCopyWithImpl<$Res, $Val extends NmeaSentence>
    implements $NmeaSentenceCopyWith<$Res> {
  _$NmeaSentenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NmeaSentence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? rawSentence = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NmeaSentenceType,
            rawSentence: null == rawSentence
                ? _value.rawSentence
                : rawSentence // ignore: cast_nullable_to_non_nullable
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
abstract class _$$NmeaSentenceImplCopyWith<$Res>
    implements $NmeaSentenceCopyWith<$Res> {
  factory _$$NmeaSentenceImplCopyWith(
    _$NmeaSentenceImpl value,
    $Res Function(_$NmeaSentenceImpl) then,
  ) = __$$NmeaSentenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({NmeaSentenceType type, String rawSentence, DateTime generatedAt});
}

/// @nodoc
class __$$NmeaSentenceImplCopyWithImpl<$Res>
    extends _$NmeaSentenceCopyWithImpl<$Res, _$NmeaSentenceImpl>
    implements _$$NmeaSentenceImplCopyWith<$Res> {
  __$$NmeaSentenceImplCopyWithImpl(
    _$NmeaSentenceImpl _value,
    $Res Function(_$NmeaSentenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NmeaSentence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? rawSentence = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _$NmeaSentenceImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NmeaSentenceType,
        rawSentence: null == rawSentence
            ? _value.rawSentence
            : rawSentence // ignore: cast_nullable_to_non_nullable
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
class _$NmeaSentenceImpl implements _NmeaSentence {
  const _$NmeaSentenceImpl({
    required this.type,
    required this.rawSentence,
    required this.generatedAt,
  });

  factory _$NmeaSentenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$NmeaSentenceImplFromJson(json);

  @override
  final NmeaSentenceType type;
  @override
  final String rawSentence;
  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'NmeaSentence(type: $type, rawSentence: $rawSentence, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NmeaSentenceImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.rawSentence, rawSentence) ||
                other.rawSentence == rawSentence) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, rawSentence, generatedAt);

  /// Create a copy of NmeaSentence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NmeaSentenceImplCopyWith<_$NmeaSentenceImpl> get copyWith =>
      __$$NmeaSentenceImplCopyWithImpl<_$NmeaSentenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NmeaSentenceImplToJson(this);
  }
}

abstract class _NmeaSentence implements NmeaSentence {
  const factory _NmeaSentence({
    required final NmeaSentenceType type,
    required final String rawSentence,
    required final DateTime generatedAt,
  }) = _$NmeaSentenceImpl;

  factory _NmeaSentence.fromJson(Map<String, dynamic> json) =
      _$NmeaSentenceImpl.fromJson;

  @override
  NmeaSentenceType get type;
  @override
  String get rawSentence;
  @override
  DateTime get generatedAt;

  /// Create a copy of NmeaSentence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NmeaSentenceImplCopyWith<_$NmeaSentenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
