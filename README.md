Sideloaded build "JetourGPS" — iOS app by Маратов Айдын (based on OpenGPS-NMEA, MIT). Russian/English UI, colourful theme.

# OpenGPS-NMEA

Turn your iOS or Android device into a wireless GPS. Broadcast real-time **NMEA** or **TAIP** location data over **TCP**, **UDP**, **WebSocket**, or **BLE** to any compatible navigation software on your network or the internet.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Features

| Category | Details |
|----------|---------|
| **Protocols** | NMEA 0183 (11 sentence types), TAIP (PV, AL) |
| **Connections** | Socket (multi-client), TCP Client, UDP Client, UDP Multicast, UDP Broadcast, TAIP UDP, WebSocket |
| **Networks** | WiFi, Cellular, Hotspot, Bluetooth BLE |
| **NMEA Messages** | GGA, GLL, GSA, HDG, HDM, HDT, RMC, VTG, ZDA, PASHR, GPTXT |
| **Background** | Location updates while device sleeps or app is terminated |
| **Settings** | Accuracy (4 levels), frequency (8 presets), static detection, high-contrast theme, true/magnetic north, password lock, DMS/decimal minutes display |

NMEA sentences supported, all individually togglable:

| Sentence | Description | Required |
|----------|-------------|----------|
| `$GPGGA` | Global Positioning System Fix Data | Marine GPS |
| `$GPGLL` | Geographic Position – Latitude/Longitude | Navigation |
| `$GPGSA` | DOP and Active Satellites | NASA Clipper GPS Repeater |
| `$HCHDG` | Heading — Magnetic + Deviation + Variation | Compass hardware |
| `$GPHDM` | Heading — Magnetic | Compass hardware |
| `$GPHDT` | Heading — True | Compass hardware |
| `$GPRMC` | Recommended Minimum Specific GNSS Data | Default message |
| `$GPVTG` | Velocity and Track over Ground | Navigation |
| `$GPZDA` | Time & Date | All apps |
| `$PASHR` | Inertial Attitude Data (non-standard) | MarineGPS |
| `$GPTXT` | Custom Text / Device ID | Multi-device setups |

## Architecture

```
lib/
├── core/                          # Shared utilities
│   ├── constants/                 # Presets, default values
│   ├── errors/                    # Exception types
│   ├── utils/                     # NMEA checksum, coordinate formatting
│   └── extensions/                # Dart extensions
├── data/
│   ├── services/                  # GPS (geolocator), BLE peripheral
│   ├── repositories/              # Settings (SharedPreferences)
│   └── providers/                 # Riverpod providers
├── domain/
│   ├── models/                    # Freezed immutable models
│   ├── protocols/                 # NMEA builder, TAIP builder
│   └── transmission/              # TCP/UDP/WebSocket transmitters
└── ui/
    ├── core/theme/                # Low contrast, high contrast, dark
    └── features/                  # Main screen, Settings screen
```

**State management:** Riverpod (NotifierProvider, StreamProvider)  
**Routing:** go_router  
**Code generation:** freezed, json_serializable

## Getting Started

### Prerequisites

- Flutter 3.x stable (`flutter doctor`)
- iOS: Xcode 15+, iOS 13+ deployment target
- Android: Android SDK 31+, minSdk 21

### Setup

```bash
git clone https://github.com/your-org/OpenGPS-NMEA.git
cd OpenGPS-NMEA
flutter pub get
```

### Run

```bash
# iOS
flutter run -d iphone

# Android
flutter run -d android
```

### Build

```bash
flutter build ios --release
flutter build apk --release
```

## Connection Methods

| Mode | Direction | Use Case |
|------|-----------|---------|
| **Socket** | Server — listen on port | OpenCPN, Aqua Map, iNavX, QtVlm |
| **TCP Client** | Push to remote IP:port | Long-distance relay servers |
| **UDP Client** | Unicast datagrams | Low-latency single target |
| **UDP Multicast** | Group (224–239.x.x.x) | Multiple receivers on same network |
| **UDP Broadcast** | Subnet broadcast (.255) | All hosts on local network |
| **TAIP UDP** | TAIP protocol server | Fleet tracking, vehicle telemetry |
| **WebSocket** | WS server connection | Web apps, real-time dashboards |

## BLE Implementation

OpenGPS-NMEA implements the **Bluetooth SIG Location and Navigation Service (UUID `0x1819`)** as a BLE peripheral:

```
Service: 0x1819 (Location and Navigation)
├── 0x2A6A — LN Feature [Read]
├── 0x2A67 — Location and Speed [Notify]
└── 0x2A68 — Navigation [Notify]
```

| Characteristic | Supported Fields |
|---------------|-----------------|
| LN Feature | Instantaneous Speed, Location, Elevation, Heading, UTC Time |
| Location & Speed | Speed (0.01 m/s), Lat/Lon (1e-7°), Elevation (0.01 m), Heading (0.01°), UTC timestamp |
| Navigation | Bearing, Heading |

**Compatible with:** SeaNav, QTH.app, LightBlue, BLE Scanner — any app implementing the BLE LNS GATT profile.

## Testing

```bash
flutter test                    # All unit + widget tests (167 tests)
flutter test test/core/         # Utility tests only
flutter test integration_test/  # E2E integration tests
```

## License

MIT — see [LICENSE](LICENSE) for details.
