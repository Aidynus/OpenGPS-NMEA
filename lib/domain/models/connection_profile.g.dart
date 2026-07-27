// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionProfileImpl _$$ConnectionProfileImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionProfileImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  connectionMethodIndex: (json['connectionMethodIndex'] as num).toInt(),
  targetIpAddress: json['targetIpAddress'] as String,
  targetPort: (json['targetPort'] as num).toInt(),
  multicastGroupAddress: json['multicastGroupAddress'] as String,
  socketPort: (json['socketPort'] as num).toInt(),
  websocketPort: (json['websocketPort'] as num).toInt(),
  websocketUrl: json['websocketUrl'] as String?,
  taipDeviceId: json['taipDeviceId'] as String,
);

Map<String, dynamic> _$$ConnectionProfileImplToJson(
  _$ConnectionProfileImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'connectionMethodIndex': instance.connectionMethodIndex,
  'targetIpAddress': instance.targetIpAddress,
  'targetPort': instance.targetPort,
  'multicastGroupAddress': instance.multicastGroupAddress,
  'socketPort': instance.socketPort,
  'websocketPort': instance.websocketPort,
  'websocketUrl': instance.websocketUrl,
  'taipDeviceId': instance.taipDeviceId,
};
