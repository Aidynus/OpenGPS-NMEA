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

abstract class DefaultSettings {
  static const double staticThresholdMeters = 1.5;
  static const int defaultPort = 11123;
  static const String defaultMulticastAddress = '239.192.1.1';
  static const int liteTimeoutSeconds = 240;
  static const String defaultTaipDeviceId = 'D001';
}
