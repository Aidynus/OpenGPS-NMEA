import 'dart:async';

import 'package:flutter/services.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/models/gps_position.dart';
import 'package:opengps_nmea/domain/protocols/ble/lns_encoder.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

/// A readable error for the UI (shown in the snackbar and translated).
class BleTransmitterException implements Exception {
  final String message;
  const BleTransmitterException(this.message);

  @override
  String toString() => message;
}

/// iPhone as a Bluetooth LE peripheral: advertises the standard Location and
/// Navigation Service (0x1819) and notifies the Location and Speed
/// characteristic (0x2A67). At most [maxClients] head units/phones receive
/// data at the same time (enforced by the native CoreBluetooth side).
class BleTransmitter extends BaseTransmitter {
  static const int maxClients = 2;
  static const String deviceName = 'JetourGPS';

  static const _methods = MethodChannel('com.jetourgps/ble');
  static const _events = EventChannel('com.jetourgps/ble/events');

  StreamSubscription<dynamic>? _eventSubscription;

  @override
  Future<void> start(AppSettings settings) async {
    await _eventSubscription?.cancel();
    _eventSubscription = _events.receiveBroadcastStream().listen(
      (event) {
        if (event is! Map) return;
        final count = (event['clientCount'] as num?)?.toInt() ?? 0;
        setClientCount(count);
        if (!isRunning) return;
        setStatus(count > 0
            ? TransmitterStatus.connected
            : TransmitterStatus.connecting);
      },
      onError: (Object error) {
        setStatus(TransmitterStatus.error);
      },
    );

    bool? started;
    try {
      started = await _methods.invokeMethod<bool>('start', {
        'deviceName': deviceName,
        'maxClients': maxClients,
      });
    } on PlatformException catch (e) {
      await _eventSubscription?.cancel();
      _eventSubscription = null;
      throw BleTransmitterException(
        e.code == 'BLE_UNAVAILABLE'
            ? 'Bluetooth is turned off or unavailable. Turn on Bluetooth and allow access in iPhone Settings.'
            : 'Bluetooth error: ${e.message ?? e.code}',
      );
    } on MissingPluginException {
      await _eventSubscription?.cancel();
      _eventSubscription = null;
      throw const BleTransmitterException(
          'Bluetooth transmission is supported on iPhone only.');
    }

    if (started != true) {
      await _eventSubscription?.cancel();
      _eventSubscription = null;
      throw const BleTransmitterException(
          'Could not start Bluetooth transmission.');
    }

    setRunning(true);
    setStatus(connectedClientCount > 0
        ? TransmitterStatus.connected
        : TransmitterStatus.connecting);
  }

  @override
  Future<bool> sendPosition(GpsPosition pos) async {
    if (!isRunning) return false;
    final packet = LnsEncoder.encodeLocationAndSpeed(pos);
    if (packet == null) return false;
    try {
      final delivered =
          await _methods.invokeMethod<bool>('send', {'data': packet});
      if (delivered == true) {
        recordSuccessfulSend();
        return true;
      }
    } on PlatformException {
      // Not fatal: the next fresh GPS fix is sent instead.
    }
    return false;
  }

  @override
  Future<void> stop() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    try {
      await _methods.invokeMethod<bool>('stop');
    } on PlatformException {
      // Ignore: already stopped.
    } on MissingPluginException {
      // Not on iOS.
    }
    setRunning(false);
    setClientCount(0);
    setStatus(TransmitterStatus.idle);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
