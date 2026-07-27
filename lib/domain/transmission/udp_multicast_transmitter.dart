import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

class UdpMulticastTransmitter extends BaseTransmitter {
  RawDatagramSocket? _socket;
  InternetAddress? _groupAddress;
  int _port = 0;
  NetworkInterface? _networkInterface;

  @override
  Future<void> start(AppSettings settings) async {
    if (isRunning) return;
    setStatus(TransmitterStatus.connecting);

    _port = settings.targetPort;

    try {
      _groupAddress = InternetAddress(settings.multicastGroupAddress);

      final interfaces = await NetworkInterface.list();
      if (interfaces.isNotEmpty) {
        _networkInterface = interfaces.firstWhere(
          (iface) => iface.addresses
              .any((addr) => addr.type == InternetAddressType.IPv4),
          orElse: () => interfaces.first,
        );
      }

      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.multicastLoopback = false;

      if (_networkInterface != null) {
        _socket!.joinMulticast(_groupAddress!, _networkInterface);
      } else {
        _socket!.joinMulticast(_groupAddress!);
      }

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
    if (_socket != null && _groupAddress != null) {
      try {
        if (_networkInterface != null) {
          _socket!.leaveMulticast(_groupAddress!, _networkInterface);
        } else {
          _socket!.leaveMulticast(_groupAddress!);
        }
      } catch (e) {
        debugPrint('[UdpMulticastTransmitter] error leaving multicast: $e');
      }
    }

    _socket?.close();
    _socket = null;
    _groupAddress = null;
    _networkInterface = null;
    setClientCount(0);
    setRunning(false);
    setStatus(TransmitterStatus.idle);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning || _socket == null || _groupAddress == null) return;

    final bytes = utf8.encode(data);
    final sent = _socket!.send(bytes, _groupAddress!, _port);
    if (sent > 0) {
      recordSuccessfulSend();
    } else {
      debugPrint('[UdpMulticastTransmitter] send returned $sent (packet dropped?)');
    }
  }
}
