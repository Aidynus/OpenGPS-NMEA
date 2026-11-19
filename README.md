# JetourGPS

iPhone application that sends the phone's GPS position (coordinates, speed,
course) to the Jetour car head unit over **Bluetooth LE** (standard Location and
Navigation Service, `0x1819`).

Author: **Маратов Айдын**. Based on the open source
[OpenGPS-NMEA](https://github.com/ariqpradipa/OpenGPS-NMEA) (MIT), reduced to a
single Bluetooth transport.

- Bluetooth LE only; up to **2** devices at once
- Interface language: system / English / Русский (Settings → General → Language)
- Dark theme in the style of the Jetour head-unit application
- Protocol description: [docs/BLE_PROTOCOL.md](docs/BLE_PROTOCOL.md)

## Build (iOS, unsigned IPA)

GitHub Actions builds it on every push: **Actions → Build iOS (unsigned)** →
artifact `JetourGPS-unsigned-ipa`. Sign and install it with Sideloadly,
iloader or AltStore using your own Apple ID.

Locally (macOS with Xcode and Flutter):

```bash
flutter pub get
flutter build ios --release --no-codesign
```

## Tests

```bash
flutter test
```
