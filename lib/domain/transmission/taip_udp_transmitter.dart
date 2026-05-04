import 'dart:async';
import 'dart:io';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class TaipUdpTransmitter extends BaseTransmitter {
  RawDatagramSocket? _socket;
  InternetAddress? _targetAddress;
  int _port = 11123;

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;

    _port = settings.targetPort;

    try {
      _targetAddress = InternetAddress(settings.targetIpAddress);
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      setRunning(true);
      setClientCount(1);
    } catch (e) {
      setRunning(false);
      setClientCount(0);
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
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _socket == null || _targetAddress == null) return;

    final bytes = data.codeUnits;
    _socket!.send(bytes, _targetAddress!, _port);
  }
}