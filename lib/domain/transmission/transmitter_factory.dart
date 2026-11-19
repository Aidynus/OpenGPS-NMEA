import 'package:opengps_nmea/domain/transmission/abstract_transmitter.dart';
import 'package:opengps_nmea/domain/transmission/ble_transmitter.dart';

/// Factory interface — allows injection of a custom factory in tests.
typedef TransmitterFactory = BaseTransmitter Function();

/// Default production factory: Bluetooth LE is the only transport.
BaseTransmitter createTransmitter() => BleTransmitter();
