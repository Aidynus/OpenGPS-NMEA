# Jetour head-unit client requirements (Android 9 / API 28)

This document is the implementation contract for the Android application running on the Jetour X90 Plus head unit. The head unit itself is the BLE central; no second Android phone is involved.

## Compatibility target
- Android 9 (API 28), Java/Kotlin implementation.
- BLE GATT Central using BluetoothLeScanner and BluetoothGatt.
- For Android 6-11 BLE scanning, declare legacy Bluetooth permissions and request ACCESS_FINE_LOCATION at runtime.
- Do not rely only on Android 12 BLUETOOTH_SCAN / BLUETOOTH_CONNECT permissions; they are unavailable on API 28.
- Check Bluetooth adapter and Location Services state before scanning.
- Scan by service UUID, not advertised local name. iOS may omit its local name from background advertising.

## GATT connection
1. Obtain BluetoothManager and its adapter.
2. Start a low-latency BLE scan filtered by service UUID 7F510001-1B15-4D5A-9A4E-7E5D0F9A1000.
3. Connect using BluetoothDevice.connectGatt(context, false, callback, BluetoothDevice.TRANSPORT_LE).
4. In onConnectionStateChange, check GATT_SUCCESS; on connected call discoverServices().
5. Find service UUID and characteristic UUID 7F510002-1B15-4D5A-9A4E-7E5D0F9A1000.
6. Enable local notifications with setCharacteristicNotification(characteristic, true), then write CCCD 00002902-0000-1000-8000-00805F9B34FB using ENABLE_NOTIFICATION_VALUE. Notifications are active only after descriptor write succeeds.
7. Handle the API 28 characteristic-change callback, which provides the changed characteristic and its value.
8. On disconnect, close the old GATT object, restart scanning and reconnect with exponential backoff (1, 2, 4, 8, 16 seconds, capped at 30 seconds). Re-discover services and re-enable CCCD on every connection.
9. Stop scan and close GATT cleanly when service stops or the user disables JetourGPS input.

## NMEA stream handling
Notifications are arbitrary byte chunks, not sentence boundaries. Maintain one byte accumulator per GATT connection:
- Append notification bytes in order.
- Split complete lines at LF (0x0A); remove optional trailing CR (0x0D).
- Decode complete lines as US-ASCII/UTF-8.
- Reject oversized unterminated buffers (suggested cap: 4096 bytes).
- Verify NMEA XOR checksum between $ and *; reject malformed or invalid checksum lines.
- Accept $GPRMC and $GPGGA; ignore unknown sentence types without disconnecting.
- Pair RMC/GGA by UTC timestamp where possible. Do not combine stale coordinates from different fixes.
- A valid RMC status must be A; GGA fix quality must be non-zero.
- Empty fields mean unavailable data. Never invent satellite count, HDOP, geoid separation, or magnetic variation.
- Reject stale fixes (suggested configurable threshold 3-5 seconds) and clear active fix on disconnect or timeout.

## Location delivery inside Android
BLE reception and Android location injection are separate modules. Keep an internal interface such as JetourFixSink.onFix(location); the BLE parser must not depend directly on a particular location-provider implementation.

For a normal third-party application on Android 9, the supported public test-provider route uses LocationManager mock/test provider APIs. The application must be selected as the mock location app in Developer Options. Android marks these locations as mock; this is not a physical GNSS provider and some navigation apps may reject or disclose mock locations.

If the requirement is for navigation apps to consume the iPhone feed as a system location source without the mock-location designation, BLE or a normal APK does not achieve that. It requires a separately designed, device-specific system integration (for example, a privileged/system component or vendor GNSS HAL/provider integration) and must be validated against actual Adayo/Autochips firmware. Do not claim this is implemented until tested on the head unit.

## Service and UI
- Run GATT central work in a foreground service while navigation input is enabled; expose connection state and last-fix age.
- Display separate states: Bluetooth unavailable, scanning, connecting, connected/subscribed, receiving valid fixes, stale/no fix, disconnected.
- Show received sentence count, last valid fix timestamp, accuracy and reconnect attempts.
- Label the source JetourGPS (iPhone BLE), not hardware GNSS.
- Log parse/checksum failures with rate limiting; do not flood logcat.
- Do not interrupt or modify existing Bluetooth Classic phone/audio connection. This protocol uses BLE GATT separately.