import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class TcpClientTransmitter extends BaseTransmitter {
  Socket? _socket;
  Timer? _reconnectTimer;
  AppSettings? _currentSettings;
  bool _intentionalStop = false;
  int _reconnectAttempts = 0;

  static const Duration _initialReconnectDelay = Duration(seconds: 3);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;

    _currentSettings = settings;
    _intentionalStop = false;
    _reconnectAttempts = 0;
    await _connect(settings);
  }

  Future<void> _connect(AppSettings settings) async {
    if (_intentionalStop) return;
    setStatus(TransmitterStatus.connecting);

    try {
      _socket = await Socket.connect(
        settings.targetIpAddress,
        settings.targetPort,
        timeout: const Duration(seconds: 5),
      );
      _reconnectAttempts = 0;
      setRunning(true);
      setClientCount(1);
      setStatus(TransmitterStatus.connected);

      _socket!.listen(
        (_) {},
        onError: (_) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
      );
    } catch (_) {
      setRunning(false);
      setClientCount(0);
      setStatus(TransmitterStatus.reconnecting);
      _scheduleReconnect();
    }
  }

  void _handleDisconnect() {
    if (_intentionalStop) return;

    _socket = null;
    setRunning(false);
    setClientCount(0);
    setStatus(TransmitterStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalStop || _currentSettings == null) return;

    _reconnectTimer?.cancel();
    final delayMs = _initialReconnectDelay.inMilliseconds *
        (1 << _reconnectAttempts.clamp(0, 4));
    final rawDelay = Duration(milliseconds: delayMs);
    final delay = rawDelay > _maxReconnectDelay ? _maxReconnectDelay : rawDelay;

    _reconnectTimer = Timer(delay, () {
      if (!_intentionalStop && _currentSettings != null) {
        _reconnectAttempts++;
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
    setStatus(TransmitterStatus.idle);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _socket == null) return;

    try {
      _socket!.add(utf8.encode(data));
      await _socket!.flush();
      recordSuccessfulSend();
    } catch (_) {
      _handleDisconnect();
    }
  }

  @override
  Future<void> sendMultiple(List<String> dataList) async {
    if (!isRunning || _socket == null || dataList.isEmpty) return;

    try {
      for (final data in dataList) {
        _socket!.add(utf8.encode(data));
      }
      await _socket!.flush();
      recordSuccessfulSend();
    } catch (_) {
      _handleDisconnect();
    }
  }
}
