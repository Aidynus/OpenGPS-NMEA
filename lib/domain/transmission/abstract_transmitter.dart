import 'dart:async';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';

/// Transmission lifecycle state.
enum TransmitterStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  error,
}

abstract class BaseTransmitter {
  final _clientCountController = StreamController<int>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  final _statusController = StreamController<TransmitterStatus>.broadcast();

  bool _isRunning = false;
  int _connectedClientCount = 0;
  TransmitterStatus _status = TransmitterStatus.idle;
  DateTime? _lastSuccessfulSend;

  Stream<int> get clientCountStream => _clientCountController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<TransmitterStatus> get statusStream => _statusController.stream;

  bool get isRunning => _isRunning;
  int get connectedClientCount => _connectedClientCount;
  TransmitterStatus get status => _status;
  DateTime? get lastSuccessfulSend => _lastSuccessfulSend;

  Future<void> start(AppSettings settings);
  Future<void> stop();
  /// Sends one position. Returns true when it was delivered to at least one
  /// connected device.
  Future<bool> sendPosition(GpsPosition pos);

  void dispose() {
    _clientCountController.close();
    _connectionStateController.close();
    _statusController.close();
  }

  // ── Protected helpers ───────────────────────────────────────────────────

  void setRunning(bool value) {
    _isRunning = value;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(value);
    }
  }

  void setStatus(TransmitterStatus s) {
    _status = s;
    if (!_statusController.isClosed) {
      _statusController.add(s);
    }
  }

  void setClientCount(int count) {
    _connectedClientCount = count;
    if (!_clientCountController.isClosed) {
      _clientCountController.add(count);
    }
  }

  void incrementClientCount() => setClientCount(_connectedClientCount + 1);

  void decrementClientCount() {
    if (_connectedClientCount > 0) {
      setClientCount(_connectedClientCount - 1);
    }
  }

  void recordSuccessfulSend() {
    _lastSuccessfulSend = DateTime.now();
  }
}
