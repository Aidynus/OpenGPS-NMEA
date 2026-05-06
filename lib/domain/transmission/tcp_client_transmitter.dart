import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class TcpClientTransmitter extends BaseTransmitter {
  Socket? _socket;
  Timer? _reconnectTimer;
  AppSettings? _currentSettings;
  bool _intentionalStop = false;

  static const Duration _defaultReconnectDelay = Duration(seconds: 3);

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;

    _currentSettings = settings;
    _intentionalStop = false;
    await _connect(settings);
  }

  Future<void> _connect(AppSettings settings) async {
    if (_intentionalStop) return;

    try {
      _socket = await Socket.connect(
        settings.targetIpAddress,
        settings.targetPort,
        timeout: const Duration(seconds: 5),
      );
      setRunning(true);
      setClientCount(1);

      _socket!.listen(
        (_) {},
        onError: (_) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
      );
    } catch (_) {
      setRunning(false);
      setClientCount(0);
      _scheduleReconnect();
    }
  }

  void _handleDisconnect() {
    if (_intentionalStop) return;

    _socket = null;
    setRunning(false);
    setClientCount(0);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalStop || _currentSettings == null) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_defaultReconnectDelay, () {
      if (!_intentionalStop && _currentSettings != null) {
        _connect(_currentSettings!);
      }
    });
  }

  @override
  Future<void> stop() async {
    _intentionalStop = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      await _socket?.close();
    } catch (e) {
      debugPrint('[TcpClientTransmitter] error closing socket: $e');
    }
    _socket = null;

    setClientCount(0);
    setRunning(false);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _socket == null) return;

    try {
      _socket!.add(data.codeUnits);
      await _socket!.flush();
    } catch (_) {
      _handleDisconnect();
    }
  }
}