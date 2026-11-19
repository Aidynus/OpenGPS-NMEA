import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:opengps_nmea/core/constants/app_constants.dart';
import 'package:opengps_nmea/domain/models/app_settings.dart';
import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';

/// iOS CoreBluetooth GATT peripheral used by the JetourGPS vehicle link.
class JetourBleTransmitter extends BaseTransmitter {
  static const _methods = MethodChannel('com.jetourgps/ble');
  static const _events = EventChannel('com.jetourgps/ble/events');

  StreamSubscription<dynamic>? _eventSubscription;

  @override
  Future<void> start(AppSettings settings) async {
    if (!Platform.isIOS) {
      throw UnsupportedError(
        'JetourGPS BLE peripheral mode currently requires iOS.',
      );
    }

    _eventSubscription = _events.receiveBroadcastStream().listen(
      (event) {
        if (event is! Map) return;
        final count = (event['clientCount'] as num?)?.toInt() ?? 0;
        setClientCount(count);
        if (count > 0) {
          setStatus(TransmitterStatus.connected);
        } else if (isRunning) {
          setStatus(TransmitterStatus.reconnecting);
        }
      },
      onError: (Object error) {
        setStatus(TransmitterStatus.error);
      },
    );

    final started = await _methods.invokeMethod<bool>('start', {
      'deviceName': settings.bleDeviceName.trim().isEmpty ||
              settings.bleDeviceName.trim() == 'OpenGPS-NMEA'
          ? DefaultSettings.defaultBleDeviceName
          : settings.bleDeviceName.trim(),
    });
    if (started != true) {
      await _eventSubscription?.cancel();
      _eventSubscription = null;
      throw StateError('iOS did not start the JetourGPS BLE peripheral.');
    }

    setRunning(true);
    setStatus(TransmitterStatus.connected);
  }

  @override
  Future<void> send(String data) async {
    if (!isRunning) throw StateError('JetourGPS BLE is not running.');
    final sent = await _methods.invokeMethod<bool>('send', {'data': data});
    if (sent != true) {
      // Advertising may be active before the car subscribes. Do not queue
      // stale coordinates; the next fresh GPS update will be sent instead.
      return;
    }
    recordSuccessfulSend();
  }

  @override
  Future<void> stop() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (Platform.isIOS) {
      await _methods.invokeMethod<bool>('stop');
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
