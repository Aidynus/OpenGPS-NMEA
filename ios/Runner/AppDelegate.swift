import Flutter
import UIKit
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var jetourBlePeripheral: JetourBlePeripheral?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let methodChannel = FlutterMethodChannel(
      name: "com.jetourgps/ble",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: "com.jetourgps/ble/events",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    let peripheral = JetourBlePeripheral()
    jetourBlePeripheral = peripheral
    methodChannel.setMethodCallHandler { [weak peripheral] call, result in
      peripheral?.handle(call, result: result)
    }
    eventChannel.setStreamHandler(peripheral)
  }
}

private final class JetourBlePeripheral: NSObject, CBPeripheralManagerDelegate, FlutterStreamHandler {
  private let serviceUUID = CBUUID(string: "7F510001-1B15-4D5A-9A4E-7E5D0F9A1000")
  private let txUUID = CBUUID(string: "7F510002-1B15-4D5A-9A4E-7E5D0F9A1000")
  private var manager: CBPeripheralManager!
  private var txCharacteristic: CBMutableCharacteristic?
  private var eventSink: FlutterEventSink?
  private var pendingStartResult: FlutterResult?
  private var deviceName = "JetourGPS"
  private var subscribedCentralIDs = Set<UUID>()
  private var pendingChunks: [Data] = []
  private var isAdvertising = false

  override init() {
    super.init()
    manager = CBPeripheralManager(
      delegate: self,
      queue: nil,
      options: [CBPeripheralManagerOptionShowPowerAlertKey: true]
    )
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "start":
      let args = call.arguments as? [String: Any]
      let requestedName = (args?["deviceName"] as? String)?
        .trimmingCharacters(in: .whitespacesAndNewlines)
      if let requestedName, !requestedName.isEmpty {
        deviceName = String(requestedName.prefix(24))
      }
      guard manager.state == .poweredOn else {
        if manager.state == .unknown || manager.state == .resetting {
          pendingStartResult = result
        } else {
          result(FlutterError(
            code: "BLE_UNAVAILABLE",
            message: "Bluetooth is not powered on or is unavailable.",
            details: manager.state.rawValue
          ))
        }
        return
      }
      beginAdvertising(result: result)

    case "stop":
      pendingStartResult = nil
      manager.stopAdvertising()
      manager.removeAllServices()
      txCharacteristic = nil
      pendingChunks.removeAll()
      subscribedCentralIDs.removeAll()
      isAdvertising = false
      emitState()
      result(true)

    case "send":
      guard isAdvertising, !subscribedCentralIDs.isEmpty else {
        result(false)
        return
      }
      guard let args = call.arguments as? [String: Any],
            let text = args["data"] as? String,
            let data = text.data(using: .utf8) else {
        result(FlutterError(code: "INVALID_DATA", message: "Expected UTF-8 NMEA text.", details: nil))
        return
      }
      // A conservative 20-byte payload works with the default ATT MTU.
      // NMEA line boundaries are deliberately not tied to notification boundaries.
      var offset = 0
      while offset < data.count {
        let end = min(offset + 20, data.count)
        pendingChunks.append(data.subdata(in: offset..<end))
        offset = end
      }
      drainNotifications()
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func beginAdvertising(result: @escaping FlutterResult) {
    pendingStartResult = result
    manager.stopAdvertising()
    manager.removeAllServices()
    subscribedCentralIDs.removeAll()
    pendingChunks.removeAll()
    isAdvertising = false

    let characteristic = CBMutableCharacteristic(
      type: txUUID,
      properties: [.notify],
      value: nil,
      permissions: []
    )
    let service = CBMutableService(type: serviceUUID, primary: true)
    service.characteristics = [characteristic]
    txCharacteristic = characteristic
    manager.add(service)
  }

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if peripheral.state == .poweredOn, let result = pendingStartResult {
      beginAdvertising(result: result)
    } else if peripheral.state != .poweredOn, let result = pendingStartResult {
      pendingStartResult = nil
      result(FlutterError(
        code: "BLE_UNAVAILABLE",
        message: "Bluetooth became unavailable.",
        details: peripheral.state.rawValue
      ))
    }
    if peripheral.state != .poweredOn {
      isAdvertising = false
      subscribedCentralIDs.removeAll()
      pendingChunks.removeAll()
    }
    emitState()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    if let error {
      let result = pendingStartResult
      pendingStartResult = nil
      result?(FlutterError(code: "BLE_SERVICE_ERROR", message: error.localizedDescription, details: nil))
      return
    }
    peripheral.startAdvertising([
      CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
      CBAdvertisementDataLocalNameKey: deviceName
    ])
  }

  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    if let error {
      isAdvertising = false
      let result = pendingStartResult
      pendingStartResult = nil
      result?(FlutterError(
        code: "BLE_ADVERTISING_ERROR",
        message: error.localizedDescription,
        details: nil
      ))
    } else {
      isAdvertising = true
      let result = pendingStartResult
      pendingStartResult = nil
      result?(true)
    }
    emitState()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didSubscribeTo characteristic: CBCharacteristic, by central: CBCentral) {
    subscribedCentralIDs.insert(central.identifier)
    emitState()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didUnsubscribeFrom characteristic: CBCharacteristic, by central: CBCentral) {
    subscribedCentralIDs.remove(central.identifier)
    emitState()
  }

  func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    drainNotifications()
  }

  private func drainNotifications() {
    guard let characteristic = txCharacteristic, !subscribedCentralIDs.isEmpty else {
      pendingChunks.removeAll()
      return
    }
    while let chunk = pendingChunks.first {
      if manager.updateValue(chunk, for: characteristic, onSubscribedCentrals: nil) {
        pendingChunks.removeFirst()
      } else {
        break
      }
    }
  }

  private func emitState() {
    eventSink?([
      "advertising": isAdvertising,
      "connected": !subscribedCentralIDs.isEmpty,
      "clientCount": subscribedCentralIDs.count
    ])
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    emitState()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
