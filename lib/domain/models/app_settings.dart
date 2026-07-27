import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/app_constants.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Type-safe protocol selector — replaces the raw [int] protocolIndex.
enum ProtocolType {
  nmea,
  taip;

  static ProtocolType fromIndex(int presetIndex) =>
      presetIndex == ProtocolPreset.taip ? ProtocolType.taip : ProtocolType.nmea;

  int get toPresetIndex => this == ProtocolType.taip ? ProtocolPreset.taip : ProtocolPreset.nmea;
}

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required int protocolIndex,
    required int connectionMethodIndex,
    required int networkIndex,
    required int frequencyIndex,
    required int accuracyIndex,
    required bool operateInBackground,
    required bool sendInOneTransmission,
    required bool highContrast,
    required bool trueNorth,
    required bool operateWhenTerminated,
    required bool disableWhenStatic,
    required bool displayDecimalMinutes,
    String? passwordHash,
    required String targetIpAddress,
    required int targetPort,
    required String multicastGroupAddress,
    required int socketPort,
    required String taipDeviceId,
    required bool bleEnabled,
    required String bleDeviceName,
    String? customGptxt,
    required int websocketPort,
    String? websocketUrl,
    required double staticThresholdMeters,
    required int speedUnitIndex,
    required bool ggaEnabled,
    required bool gllEnabled,
    required bool gsaEnabled,
    required bool hdgEnabled,
    required bool hdmEnabled,
    required bool hdtEnabled,
    required bool rmcEnabled,
    required bool vtgEnabled,
    required bool zdaEnabled,
    required bool pashrEnabled,
    required bool gptxtEnabled,
    required bool taipPvEnabled,
    required bool taipAlEnabled,
  }) = _AppSettings;

  const AppSettings._();

  // ── Derived convenience accessors ──────────────────────────────────

  /// Typed protocol accessor — avoids raw-int comparisons in the codebase.
  ProtocolType get protocol => ProtocolType.fromIndex(protocolIndex);

  factory AppSettings.defaults() => const AppSettings(
        protocolIndex: DefaultSettings.defaultProtocolIndex,
        connectionMethodIndex: DefaultSettings.defaultConnectionMethodIndex,
        networkIndex: DefaultSettings.defaultNetworkIndex,
        frequencyIndex: DefaultSettings.defaultFrequencyIndex,
        accuracyIndex: DefaultSettings.defaultAccuracyIndex,
        operateInBackground: DefaultSettings.operateInBackground,
        sendInOneTransmission: DefaultSettings.sendInOneTransmission,
        highContrast: false,
        trueNorth: false,
        operateWhenTerminated: false,
        disableWhenStatic: false,
        displayDecimalMinutes: false,
        passwordHash: null,
        targetIpAddress: DefaultSettings.defaultTargetIpAddress,
        targetPort: DefaultSettings.defaultPort,
        multicastGroupAddress: DefaultSettings.defaultMulticastAddress,
        socketPort: DefaultSettings.defaultPort,
        taipDeviceId: DefaultSettings.defaultTaipDeviceId,
        bleEnabled: false,
        bleDeviceName: DefaultSettings.defaultBleDeviceName,
        customGptxt: null,
        websocketPort: DefaultSettings.defaultWebsocketPort,
        websocketUrl: null,
        staticThresholdMeters: DefaultSettings.staticThresholdMeters,
        speedUnitIndex: DefaultSettings.defaultSpeedUnitIndex,
        ggaEnabled: true,
        gllEnabled: false,
        gsaEnabled: false,
        hdgEnabled: false,
        hdmEnabled: false,
        hdtEnabled: false,
        rmcEnabled: true,
        vtgEnabled: false,
        zdaEnabled: false,
        pashrEnabled: false,
        gptxtEnabled: false,
        taipPvEnabled: true,
        taipAlEnabled: false,
      );

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
