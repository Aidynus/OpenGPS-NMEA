// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NetworkInfoImpl _$$NetworkInfoImplFromJson(Map<String, dynamic> json) =>
    _$NetworkInfoImpl(
      wifiIp: json['wifiIp'] as String?,
      cellularIp: json['cellularIp'] as String?,
      hotspotIp: json['hotspotIp'] as String?,
      hotspotSubnet: json['hotspotSubnet'] as String?,
      isHotspotActive: json['isHotspotActive'] as bool,
    );

Map<String, dynamic> _$$NetworkInfoImplToJson(_$NetworkInfoImpl instance) =>
    <String, dynamic>{
      'wifiIp': instance.wifiIp,
      'cellularIp': instance.cellularIp,
      'hotspotIp': instance.hotspotIp,
      'hotspotSubnet': instance.hotspotSubnet,
      'isHotspotActive': instance.isHotspotActive,
    };
