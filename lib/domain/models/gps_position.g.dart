// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GpsPositionImpl _$$GpsPositionImplFromJson(Map<String, dynamic> json) =>
    _$GpsPositionImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      hasFix: json['hasFix'] as bool,
      verticalAccuracy: (json['verticalAccuracy'] as num?)?.toDouble(),
      headingAccuracy: (json['headingAccuracy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$GpsPositionImplToJson(_$GpsPositionImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'speed': instance.speed,
      'heading': instance.heading,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp.toIso8601String(),
      'hasFix': instance.hasFix,
      'verticalAccuracy': instance.verticalAccuracy,
      'headingAccuracy': instance.headingAccuracy,
    };
