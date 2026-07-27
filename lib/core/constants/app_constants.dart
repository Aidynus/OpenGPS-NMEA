abstract class GpsAccuracyPreset {
  static const int best = 0;
  static const int good = 1;
  static const int moderate = 2;
  static const int lazy = 3;
}

abstract class TransmissionFrequencyPreset {
  static const int noDelay = 0;
  static const int oneSecond = 1;
  static const int fiveSeconds = 2;
  static const int thirtySeconds = 3;
  static const int sixtySeconds = 4;
  static const int fiveMinutes = 5;
  static const int thirtyMinutes = 6;
  static const int oneHour = 7;

  static Duration fromIndex(int index) {
    switch (index) {
      case noDelay:
        return Duration.zero;
      case oneSecond:
        return const Duration(seconds: 1);
      case fiveSeconds:
        return const Duration(seconds: 5);
      case thirtySeconds:
        return const Duration(seconds: 30);
      case sixtySeconds:
        return const Duration(seconds: 60);
      case fiveMinutes:
        return const Duration(minutes: 5);
      case thirtyMinutes:
        return const Duration(minutes: 30);
      case oneHour:
        return const Duration(hours: 1);
      default:
        return const Duration(seconds: 1);
    }
  }
}

abstract class ConnectionMethodPreset {
  static const int socket = 0;
  static const int tcpClient = 1;
  static const int udpClient = 2;
  static const int udpMulticast = 3;
  static const int udpBroadcast = 4;
  static const int taipUdp = 5;
  static const int webSocket = 6;
}

abstract class ProtocolPreset {
  static const int nmea = 0;
  static const int taip = 1;
}

abstract class NetworkPreset {
  static const int wifi = 0;
  static const int cellular = 1;
  static const int hotspot = 2;
  static const int ble = 3;
}

/// Speed unit presets for display and export.
abstract class SpeedUnitPreset {
  static const int knots = 0;
  static const int kmh = 1;
  static const int mph = 2;
  static const int ms = 3;
}

/// Single source of truth for all default app settings.
///
/// Every default value is defined here exactly once. [AppSettings.defaults()],
/// [SettingsRepository] fallbacks, and [SettingsRepository.resetToDefaults()]
/// all reference these constants so a change here propagates everywhere.
abstract class DefaultSettings {
  // ── Operational ─────────────────────────────────────────────────────
  static const bool operateInBackground = true;
  static const bool sendInOneTransmission = false;
  static const int defaultFrequencyIndex = TransmissionFrequencyPreset.fiveSeconds;
  static const int defaultAccuracyIndex = GpsAccuracyPreset.best;
  static const int defaultProtocolIndex = ProtocolPreset.nmea;
  static const int defaultConnectionMethodIndex = ConnectionMethodPreset.socket;
  static const int defaultNetworkIndex = NetworkPreset.wifi;

  // ── Network ─────────────────────────────────────────────────────────
  static const int defaultPort = 11123;
  static const int defaultWebsocketPort = 8080;
  static const String defaultMulticastAddress = '239.255.255.250';
  static const String defaultTargetIpAddress = '192.168.1.255';

  // ── TAIP ────────────────────────────────────────────────────────────
  static const String defaultTaipDeviceId = 'D001';

  // ── GPS ─────────────────────────────────────────────────────────────
  static const double staticThresholdMeters = 1.5;

  // ── BLE ─────────────────────────────────────────────────────────────
  static const String defaultBleDeviceName = 'OpenGPS-NMEA';

  // ── Display ─────────────────────────────────────────────────────────
  static const int defaultSpeedUnitIndex = SpeedUnitPreset.knots;

  // ── Timeouts ────────────────────────────────────────────────────────
  static const int liteTimeoutSeconds = 240;
  static const int tcpKeepaliveSeconds = 30;
  static const int tcpIdleTimeoutSeconds = 120;
}

/// Centralized key names for [SharedPreferences] storage.
///
/// Using a single constant per key ensures that a typo cannot silently
/// fall through to a default value, losing user data.
abstract class SettingsKeys {
  static const String protocolIndex = 'protocolIndex';
  static const String connectionMethodIndex = 'connectionMethodIndex';
  static const String networkIndex = 'networkIndex';
  static const String frequencyIndex = 'frequencyIndex';
  static const String accuracyIndex = 'accuracyIndex';
  static const String operateInBackground = 'operateInBackground';
  static const String sendInOneTransmission = 'sendInOneTransmission';
  static const String highContrast = 'highContrast';
  static const String trueNorth = 'trueNorth';
  static const String operateWhenTerminated = 'operateWhenTerminated';
  static const String disableWhenStatic = 'disableWhenStatic';
  static const String displayDecimalMinutes = 'displayDecimalMinutes';
  static const String passwordHash = 'passwordHash';
  static const String targetIpAddress = 'targetIpAddress';
  static const String targetPort = 'targetPort';
  static const String multicastGroupAddress = 'multicastGroupAddress';
  static const String socketPort = 'socketPort';
  static const String websocketPort = 'websocketPort';
  static const String websocketUrl = 'websocketUrl';
  static const String taipDeviceId = 'taipDeviceId';
  static const String taipPvEnabled = 'taipPvEnabled';
  static const String taipAlEnabled = 'taipAlEnabled';
  static const String bleEnabled = 'bleEnabled';
  static const String bleDeviceName = 'bleDeviceName';
  static const String customGptxt = 'customGptxt';
  static const String staticThresholdMeters = 'staticThresholdMeters';
  static const String ggaEnabled = 'ggaEnabled';
  static const String gllEnabled = 'gllEnabled';
  static const String gsaEnabled = 'gsaEnabled';
  static const String hdgEnabled = 'hdgEnabled';
  static const String hdmEnabled = 'hdmEnabled';
  static const String hdtEnabled = 'hdtEnabled';
  static const String rmcEnabled = 'rmcEnabled';
  static const String vtgEnabled = 'vtgEnabled';
  static const String zdaEnabled = 'zdaEnabled';
  static const String pashrEnabled = 'pashrEnabled';
  static const String gptxtEnabled = 'gptxtEnabled';
  static const String speedUnitIndex = 'speedUnitIndex';
  static const String connectionProfiles = 'connectionProfiles';
}
