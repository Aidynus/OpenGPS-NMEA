# JetourGPS BLE protocol (iPhone peripheral -> Android head unit)

Version: 1.0  
Role: iPhone is the BLE GATT peripheral; the Jetour head unit is the BLE central.

## GATT

- Service UUID: `7F510001-1B15-4D5A-9A4E-7E5D0F9A1000`
- NMEA TX characteristic UUID: `7F510002-1B15-4D5A-9A4E-7E5D0F9A1000`
- Characteristic properties: `NOTIFY`
- Characteristic permissions: none (notifications only)
- Security: no application-level pairing or authentication in protocol v1.
- Device local name: configured in JetourGPS settings; default `JetourGPS`.

The Android central must scan for the service UUID, connect, discover the service and TX characteristic, enable notifications (CCCD), then consume the byte stream.

## Payload framing

Payload is UTF-8 NMEA 0183 text. Each sentence ends with CRLF (`\r\n`). The TX characteristic is a byte stream: a sentence may span more than one BLE notification and a notification may contain a partial sentence. The Android client MUST accumulate bytes until LF (0x0A), strip optional CR (0x0D), then parse the complete sentence. Do not assume one notification equals one sentence.

The iOS peripheral uses CoreBluetooth `updateValue(_:for:onSubscribedCentrals:)` and respects its back-pressure callback. The maximum notification size is negotiated by CoreBluetooth; clients must support arbitrary chunk boundaries.

## NMEA sentence set

JetourGPS mode emits:
- `$GPRMC` — UTC time/date, validity, latitude, longitude, speed over ground (knots), course over ground (degrees).
- `$GPGGA` — UTC time, latitude, longitude, fix quality, altitude (metres).

Only RMC and GGA are required by the first Android client. Data unavailable from iOS Core Location (satellite count, per-satellite IDs, HDOP, geoid separation, magnetic variation) must not be fabricated. Empty NMEA fields are preferable to invented measurements. RMC/GGA checksums are XOR of bytes between '$' (excluded) and '*' (excluded), represented as two uppercase hexadecimal digits.

Coordinates use NMEA degrees-and-decimal-minutes format. Speed is knots. Course is degrees true. Timestamps are UTC.

## Connection and lifecycle

- The iPhone advertises only while JetourGPS transmission is enabled.
- The Android central should reconnect with exponential backoff when the link drops and re-enable notifications after every reconnect.
- One connected central is sufficient for the vehicle use case. The iOS peripheral may reject/ignore additional subscribers.
- The iOS app reports advertising separately from a subscribed central connection.
- iOS background BLE behavior is subject to CoreBluetooth background execution and advertising restrictions. Force-quitting the app stops its background execution; continuous operation after force quit is not guaranteed.

## Android integration requirements

1. Implement a BLE GATT central, not a classic Bluetooth RFCOMM client.
2. Scan using the exact service UUID above; do not depend on local-name filtering (iOS background advertising can omit the local name).
3. Connect and discover the service/characteristic; enable CCCD notifications.
4. Reassemble notification bytes into CRLF-delimited NMEA lines.
5. Validate NMEA checksum and freshness; treat missing/invalid fixes as no-fix.
6. Feed parsed fixes into the intended Android location integration. A BLE feed alone does not make Android report a physical GNSS provider: the Android-side provider integration is a separate system-level task. A mock location provider is marked as mock by Android and is not equivalent to hardware GNSS.

## Compatibility note

Do not use Bluetooth SIG Location and Navigation Service UUID 0x1819 for these NMEA payloads. Its standard characteristics use Bluetooth SIG binary structures, not NMEA text.
