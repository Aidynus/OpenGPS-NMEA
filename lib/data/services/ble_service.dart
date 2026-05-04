import 'dart:async';
import 'dart:typed_data';

import 'package:opengps_nmea/domain/models/gps_position.dart';

import 'ble_data_encoder.dart';

class BleLocationUuids {
  BleLocationUuids._();

  static const String service = '00001819-0000-1000-8000-00805F9B34FB';
  static const String lnFeature = '00002A6A-0000-1000-8000-00805F9B34FB';
  static const String locationAndSpeed = '00002A67-0000-1000-8000-00805F9B34FB';
  static const String navigation = '00002A68-0000-1000-8000-00805F9B34FB';
}

abstract class BlePeripheralAdapter {
  Future<bool> startAdvertising(String deviceName, List<String> serviceUuids);
  Future<void> stopAdvertising();
  Future<void> notifyCharacteristic(String charUuid, Uint8List value);
  Future<Uint8List?> readCharacteristic(String charUuid);
  Stream<bool> get connectionStateStream;
  bool get isAdvertising;
  bool get isConnected;
  Future<void> setMtu(int mtu);
  void dispose();
}

class BleLocationService {
  final BlePeripheralAdapter _adapter;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  BleLocationService(this._adapter);

  bool get isAdvertising => _adapter.isAdvertising;
  bool get isConnected => _adapter.isConnected;
  Stream<bool> get connectionStateStream => _connectionController.stream;

  Future<void> initialize() async {
    _adapter.connectionStateStream.listen((connected) {
      _connectionController.add(connected);
    });
  }

  Future<bool> startAdvertising(String deviceName) async {
    final result = await _adapter.startAdvertising(deviceName, [
      BleLocationUuids.service,
    ]);
    return result;
  }

  Future<void> stopAdvertising() async {
    await _adapter.stopAdvertising();
  }

  Future<void> updateLocationAndSpeed(GpsPosition pos) async {
    final encoded = BleDataEncoder.encodeLocationAndSpeed(pos);
    await _adapter.notifyCharacteristic(BleLocationUuids.locationAndSpeed, encoded);
  }

  Future<void> updateNavigation(GpsPosition pos) async {
    final encoded = BleDataEncoder.encodeNavigation(pos);
    await _adapter.notifyCharacteristic(BleLocationUuids.navigation, encoded);
  }

  Future<Uint8List?> readLnFeature() async {
    return _adapter.readCharacteristic(BleLocationUuids.lnFeature);
  }

  Future<void> setMtu(int mtu) async {
    await _adapter.setMtu(mtu);
  }

  void dispose() {
    _connectionController.close();
    _adapter.dispose();
  }
}
