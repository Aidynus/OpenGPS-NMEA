import Flutter
import UIKit
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var blePeripheral: JetourBlePeripheral?

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
    blePeripheral = peripheral
    methodChannel.setMethodCallHandler { [weak peripheral] call, result in
      peripheral?.handle(call, result: result)
    }
    eventChannel.setStreamHandler(peripheral)
  }
}

/// iPhone as a BLE peripheral: standard Location and Navigation Service (0x1819).
///  - 0x2A67 Location and Speed  (notify)  - position packets
///  - 0x2A6A LN Feature          (read)    - what the packets contain
/// At most `maxClients` central devices receive data; further ones are ignored
/// and, while the limit is reached, the iPhone stops advertising.
private final class JetourBlePeripheral: NSObject, CBPeripheralManagerDelegate, FlutterStreamHandler {
  private let lnServiceUUID = CBUUID(string: "1819")
  private let locationSpeedUUID = CBUUID(string: "2A67")
  private let lnFeatureUUID = CBUUID(string: "2A6A")

  private var manager: CBPeripheralManager!
  private var locationCharacteristic: CBMutableCharacteristic?
  private var eventSink: FlutterEventSink?
  private var pendingStartResult: FlutterResult?

  private var deviceName = "JetourGPS"
  private var maxClients = 2
  private var wantAdvertising = false
  private var advertising = false

  /// Centrals that receive position data (at most `maxClients`).
  private var activeCentrals: [CBCentral] = []
  /// Centrals subscribed beyond the limit: they get nothing until a slot frees up.
  private var waitingCentrals: [CBCentral] = []
  /// Latest packet that could not be delivered yet (BLE queue was full).
  private var pendingPacket: Data?

  override init() {
    super.init()
    manager = CBPeripheralManager(
      delegate: self,
      queue: nil,
      options: [CBPeripheralManagerOptionShowPowerAlertKey: true]
    )
  }

  // MARK: Flutter method channel

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "start":
      let args = call.arguments as? [String: Any]
      if let name = (args?["deviceName"] as? String)?
        .trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
        deviceName = String(name.prefix(24))
      }
      if let limit = (args?["maxClients"] as? NSNumber)?.intValue, limit >= 1 {
        maxClients = min(limit, 2)
      }
      wantAdvertising = true
      switch manager.state {
      case .poweredOn:
        beginAdvertising(result: result)
      case .unknown, .resetting:
        pendingStartResult = result
      default:
        wantAdvertising = false
        result(FlutterError(
          code: "BLE_UNAVAILABLE",
          message: "Bluetooth is not powered on or is unavailable.",
          details: manager.state.rawValue
        ))
      }

    case "stop":
      wantAdvertising = false
      pendingStartResult = nil
      resetConnections()
      manager.stopAdvertising()
      manager.removeAllServices()
      locationCharacteristic = nil
      advertising = false
      emitState()
      result(true)

    case "send":
      guard let args = call.arguments as? [String: Any],
            let typed = args["data"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_DATA", message: "Expected a binary packet.", details: nil))
        return
      }
      guard !activeCentrals.isEmpty else {
        result(false)
        return
      }
      if !deliver(typed.data) {
        // Keep only the newest packet: stale coordinates are useless.
        pendingPacket = typed.data
      }
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Advertising

  private func beginAdvertising(result: FlutterResult?) {
    pendingStartResult = result
    manager.stopAdvertising()
    manager.removeAllServices()
    resetConnections()
    advertising = false

    let location = CBMutableCharacteristic(
      type: locationSpeedUUID,
      properties: [.notify],
      value: nil,
      permissions: []
    )
    // LN Feature (uint32): bit0 speed, bit2 location, bit4 heading.
    let feature = CBMutableCharacteristic(
      type: lnFeatureUUID,
      properties: [.read],
      value: Data([0x15, 0x00, 0x00, 0x00]),
      permissions: [.readable]
    )
    let service = CBMutableService(type: lnServiceUUID, primary: true)
    service.characteristics = [location, feature]
    locationCharacteristic = location
    manager.add(service)
  }

  private func startAdvertisingNow() {
    guard wantAdvertising, manager.state == .poweredOn, !manager.isAdvertising else { return }
    manager.startAdvertising([
      CBAdvertisementDataServiceUUIDsKey: [lnServiceUUID],
      CBAdvertisementDataLocalNameKey: deviceName
    ])
  }

  /// While two devices are connected the iPhone stops advertising, so a third
  /// device cannot find it; advertising resumes when a slot frees up.
  private func updateAdvertisingForCapacity() {
    guard wantAdvertising, locationCharacteristic != nil else { return }
    if activeCentrals.count >= maxClients {
      if manager.isAdvertising {
        manager.stopAdvertising()
      }
      advertising = false
    } else if !manager.isAdvertising {
      startAdvertisingNow()
    }
  }

  private func resetConnections() {
    activeCentrals.removeAll()
    waitingCentrals.removeAll()
    pendingPacket = nil
  }

  // MARK: Data

  @discardableResult
  private func deliver(_ data: Data) -> Bool {
    guard let characteristic = locationCharacteristic, !activeCentrals.isEmpty else { return false }
    return manager.updateValue(data, for: characteristic, onSubscribedCentrals: activeCentrals)
  }

  // MARK: CBPeripheralManagerDelegate

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
      if wantAdvertising && locationCharacteristic == nil {
        // First start (waiting for the radio) or Bluetooth was switched back on.
        beginAdvertising(result: pendingStartResult)
      }
    case .unknown, .resetting:
      // Transitional states: keep waiting.
      break
    default:
      if let result = pendingStartResult {
        pendingStartResult = nil
        wantAdvertising = false
        result(FlutterError(
          code: "BLE_UNAVAILABLE",
          message: "Bluetooth became unavailable.",
          details: peripheral.state.rawValue
        ))
      }
      advertising = false
      locationCharacteristic = nil
      resetConnections()
    }
    emitState()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    if let error = error {
      let result = pendingStartResult
      pendingStartResult = nil
      wantAdvertising = false
      result?(FlutterError(code: "BLE_SERVICE_ERROR", message: error.localizedDescription, details: nil))
      return
    }
    startAdvertisingNow()
  }

  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    let result = pendingStartResult
    pendingStartResult = nil
    if let error = error {
      advertising = false
      wantAdvertising = false
      result?(FlutterError(code: "BLE_ADVERTISING_ERROR", message: error.localizedDescription, details: nil))
    } else {
      advertising = true
      result?(true)
    }
    emitState()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
    let id = central.identifier
    if activeCentrals.contains(where: { $0.identifier == id }) ||
        waitingCentrals.contains(where: { $0.identifier == id }) {
      return
    }
    if activeCentrals.count < maxClients {
      activeCentrals.append(central)
    } else {
      waitingCentrals.append(central)
    }
    updateAdvertisingForCapacity()
    emitState()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
    let id = central.identifier
    let wasActive = activeCentrals.contains(where: { $0.identifier == id })
    activeCentrals.removeAll(where: { $0.identifier == id })
    waitingCentrals.removeAll(where: { $0.identifier == id })
    if wasActive, activeCentrals.count < maxClients, !waitingCentrals.isEmpty {
      activeCentrals.append(waitingCentrals.removeFirst())
    }
    if activeCentrals.isEmpty {
      pendingPacket = nil
    }
    updateAdvertisingForCapacity()
    emitState()
  }

  func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    if let packet = pendingPacket, deliver(packet) {
      pendingPacket = nil
    }
  }

  // MARK: FlutterStreamHandler

  private func emitState() {
    eventSink?([
      "advertising": advertising,
      "connected": !activeCentrals.isEmpty,
      "clientCount": activeCentrals.count,
      "maxClients": maxClients
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
