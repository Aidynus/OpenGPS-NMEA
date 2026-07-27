import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class UdpBroadcastTransmitter extends BaseTransmitter {
  RawDatagramSocket? _socket;
  InternetAddress? _broadcastAddress;
  int _port = 0;

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;
    setStatus(TransmitterStatus.connecting);

    _port = settings.targetPort;

    try {
      _broadcastAddress = _calculateBroadcastAddress(settings);
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

  InternetAddress _calculateBroadcastAddress(AppSettings settings) {
    final targetIp = settings.targetIpAddress;

    if (targetIp.endsWith('.255')) {
      return InternetAddress(targetIp);
    }

    final parts = targetIp.split('.');
    if (parts.length == 4) {
      parts[3] = '255';
      return InternetAddress(parts.join('.'));
    }

    return InternetAddress(targetIp);
  }

  @override
  Future<void> stop() async {
    _socket?.close();
    _socket = null;
    _broadcastAddress = null;
    setClientCount(0);
    setRunning(false);
    setStatus(TransmitterStatus.idle);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _socket == null || _broadcastAddress == null) return;

    final bytes = utf8.encode(data);
    final sent = _socket!.send(bytes, _broadcastAddress!, _port);
    if (sent > 0) {
      recordSuccessfulSend();
    } else {
      debugPrint('[UdpBroadcastTransmitter] send returned $sent (packet dropped?)');
    }
  }
}
