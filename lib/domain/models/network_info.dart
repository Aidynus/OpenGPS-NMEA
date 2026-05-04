import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_info.freezed.dart';
part 'network_info.g.dart';

@freezed
class NetworkInfo with _$NetworkInfo {
  const factory NetworkInfo({
    String? wifiIp,
    String? cellularIp,
    String? hotspotIp,
    String? hotspotSubnet,
    required bool isHotspotActive,
  }) = _NetworkInfo;

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);
}