import 'dart:async';

import 'package:opengps_nmea/domain/models/app_settings.dart';

abstract class BaseTransmitter {
  final _clientCountController = StreamController<int>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  bool _isRunning = false;
  int _connectedClientCount = 0;

  Stream<int> get clientCountStream => _clientCountController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  bool get isRunning => _isRunning;
  int get connectedClientCount => _connectedClientCount;

  Future<void> start(AppSettings settings);
  Future<void> stop();
  Future<void> send(String data);

  Future<void> sendMultiple(List<String> dataList) async {
    for (final data in dataList) {
      await send(data);
    }
  }

  void dispose() {
    _clientCountController.close();
    _connectionStateController.close();
  }

  void setRunning(bool value) {
    _isRunning = value;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(value);
    }
  }

  void setClientCount(int count) {
    _connectedClientCount = count;
    if (!_clientCountController.isClosed) {
      _clientCountController.add(count);
    }
  }

  void incrementClientCount() {
    setClientCount(_connectedClientCount + 1);
  }

  void decrementClientCount() {
    if (_connectedClientCount > 0) {
      setClientCount(_connectedClientCount - 1);
    }
  }
}