import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class UdpClientTransmitter extends BaseTransmitter {
  RawDatagramSocket? _socket;
  InternetAddress? _targetAddress;
  int _port = 0;

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;
    setStatus(TransmitterStatus.connecting);

    _port = settings.targetPort;

    try {
      _targetAddress = InternetAddress(settings.targetIpAddress);
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.broadcastEnabled = true;
      setRunning(true);
      setClientCount(1);
      setStatus(TransmitterStatus.connected);
    } catch (e) {
      setRunning(false);
      setClientCount(0);
      setStatus(TransmitterStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _socket?.close();
    _socket = null;
    _targetAddress = null;
    setClientCount(0);
    setRunning(false);
    setStatus(TransmitterStatus.idle);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _socket == null || _targetAddress == null) return;

    final bytes = utf8.encode(data);
    final sent = _socket!.send(bytes, _targetAddress!, _port);
    if (sent > 0) {
      recordSuccessfulSend();
    } else {
      debugPrint('[UdpClientTransmitter] send returned $sent (packet dropped?)');
    }
  }
}
