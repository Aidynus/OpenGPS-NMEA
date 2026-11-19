# JetourGPS Bluetooth LE protocol (iPhone → car head unit)

Author: Маратов Айдын

The iPhone is the BLE **peripheral**; the head unit (Android) is the **central**.
The standard Bluetooth SIG **Location and Navigation Service** is used, the same
profile the head-unit application already reads (it works with GPS2IP in
Bluetooth mode as well).

| Item | UUID | Properties |
|------|------|-----------|
| Service: Location and Navigation | `0x1819` | – |
| Location and Speed | `0x2A67` | notify |
| LN Feature | `0x2A6A` | read (`0x00000015`: speed, location, heading) |

Advertised local name: `JetourGPS`. The service UUID is advertised, so the head
unit should scan by service `0x1819`, not by name.

## Location and Speed packet (little-endian)

| Field | Type | Present when | Unit |
|-------|------|--------------|------|
| flags | uint16 | always | bit0 speed, bit2 location, bit4 heading |
| speed | uint16 | bit0 | 0.01 m/s |
| latitude | sint32 | bit2 | 1e-7 degree |
| longitude | sint32 | bit2 | 1e-7 degree |
| heading | uint16 | bit4 | 0.01 degree |

Speed and heading are left out when iOS reports them as invalid (negative).
Typical packet: 14 bytes (one notification).

## Connections

At most **2** devices receive data at the same time. A third device cannot
connect: while two are subscribed the iPhone stops advertising and resumes as
soon as one disconnects. Devices that subscribe anyway (already knew the
address) receive nothing until a slot is free.

## iOS notes

- Background operation needs the *Always* location permission and Bluetooth
  permission. In the background iOS may shorten advertising data (the service
  UUID is kept, the local name may be dropped).
- Force-quitting the app stops transmission.
