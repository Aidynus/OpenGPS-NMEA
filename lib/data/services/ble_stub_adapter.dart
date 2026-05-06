import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ble_service.dart';

/// Graceful BLE peripheral stub for platforms where BLE peripheral mode
/// is not available (e.g., iOS via flutter_blue_plus).
///
/// All methods return controlled failure/no-op responses. The UI layer
/// reads [connectionStateStream] which always emits `false`, signaling
/// that BLE is not available. No exceptions are thrown to the caller.
class BleStubAdapter implements BlePeripheralAdapter {
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  BleStubAdapter() {
    // Announce immediately that BLE peripheral mode is unavailable.
    _connectionController.add(false);
  }

  @override
  Future<bool> startAdvertising(
    String deviceName,
    List<String> serviceUuids,
  ) async {
    debugPrint('[BleStubAdapter] BLE peripheral mode not available on this platform.');
    return false;
  }

  @override
  Future<void> stopAdvertising() async {
    // No-op — advertising was never started.
  }

  @override
  Future<void> notifyCharacteristic(
    String charUuid,
    Uint8List value,
  ) async {
    // No-op — no BLE peripheral to notify.
  }

  @override
  Future<Uint8List?> readCharacteristic(String charUuid) async {
    // No characteristic data available.
    return null;
  }

  @override
  Stream<bool> get connectionStateStream => _connectionController.stream;

  @override
  bool get isAdvertising => false;

  @override
  bool get isConnected => false;

  @override
  Future<void> setMtu(int mtu) async {
    // No-op — no connection to set MTU on.
  }

  @override
  void dispose() {
    _connectionController.close();
  }
}
