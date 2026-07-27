import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/app_constants.dart';

part 'connection_profile.freezed.dart';
part 'connection_profile.g.dart';

/// A saved connection preset that can be quickly switched to.
@freezed
class ConnectionProfile with _$ConnectionProfile {
  const factory ConnectionProfile({
    required String id,
    required String name,
    required int connectionMethodIndex,
    required String targetIpAddress,
    required int targetPort,
    required String multicastGroupAddress,
    required int socketPort,
    required int websocketPort,
    String? websocketUrl,
    required String taipDeviceId,
  }) = _ConnectionProfile;

  factory ConnectionProfile.fromJson(Map<String, dynamic> json) =>
      _$ConnectionProfileFromJson(json);
}

extension ConnectionProfileDefaults on ConnectionProfile {
  static ConnectionProfile defaultProfile() => ConnectionProfile(
        id: 'default',
        name: 'Default',
        connectionMethodIndex: DefaultSettings.defaultConnectionMethodIndex,
        targetIpAddress: DefaultSettings.defaultTargetIpAddress,
        targetPort: DefaultSettings.defaultPort,
        multicastGroupAddress: DefaultSettings.defaultMulticastAddress,
        socketPort: DefaultSettings.defaultPort,
        websocketPort: DefaultSettings.defaultWebsocketPort,
        websocketUrl: null,
        taipDeviceId: DefaultSettings.defaultTaipDeviceId,
      );
}
