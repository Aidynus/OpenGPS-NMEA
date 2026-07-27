// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionStatusImpl _$$ConnectionStatusImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionStatusImpl(
  status:
      $enumDecodeNullable(_$TransmissionStatusEnumMap, json['status']) ??
      TransmissionStatus.idle,
  isActive: json['isActive'] as bool? ?? false,
  isConnected: json['isConnected'] as bool? ?? false,
  connectedClientCount: (json['connectedClientCount'] as num?)?.toInt() ?? 0,
  totalTxCount: (json['totalTxCount'] as num?)?.toInt() ?? 0,
  totalRxCount: (json['totalRxCount'] as num?)?.toInt() ?? 0,
  localIpAddress: json['localIpAddress'] as String?,
  bleStatus: json['bleStatus'] as String?,
  lastTxTime: json['lastTxTime'] == null
      ? null
      : DateTime.parse(json['lastTxTime'] as String),
  activeProtocol: json['activeProtocol'] as String?,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$ConnectionStatusImplToJson(
  _$ConnectionStatusImpl instance,
) => <String, dynamic>{
  'status': _$TransmissionStatusEnumMap[instance.status]!,
  'isActive': instance.isActive,
  'isConnected': instance.isConnected,
  'connectedClientCount': instance.connectedClientCount,
  'totalTxCount': instance.totalTxCount,
  'totalRxCount': instance.totalRxCount,
  'localIpAddress': instance.localIpAddress,
  'bleStatus': instance.bleStatus,
  'lastTxTime': instance.lastTxTime?.toIso8601String(),
  'activeProtocol': instance.activeProtocol,
  'errorMessage': instance.errorMessage,
};

const _$TransmissionStatusEnumMap = {
  TransmissionStatus.idle: 'idle',
  TransmissionStatus.connecting: 'connecting',
  TransmissionStatus.connected: 'connected',
  TransmissionStatus.reconnecting: 'reconnecting',
  TransmissionStatus.error: 'error',
};
