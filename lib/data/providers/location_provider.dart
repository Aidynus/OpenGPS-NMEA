import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart' as net_info;

import '../../core/constants/app_constants.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/connection_profile.dart';
import '../../domain/models/gps_position.dart';
import '../../domain/models/network_info.dart';
import '../repositories/settings_repository.dart';
import '../services/location_service.dart';

// ── Settings ──────────────────────────────────────────────────────────────────

final settingsRepositoryProvider =
    FutureProvider<SettingsRepository>((ref) async {
  return SettingsRepository.initialize();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repoAsync = ref.watch(settingsRepositoryProvider);
    return repoAsync.when(
      data: _loadFromRepo,
      loading: () => AppSettings.defaults(),
      error: (_, __) => AppSettings.defaults(),
    );
  }

  AppSettings _loadFromRepo(SettingsRepository repo) {
    return AppSettings(
      protocolIndex: repo.protocolIndex,
      connectionMethodIndex: repo.connectionMethodIndex,
      networkIndex: repo.networkIndex,
      frequencyIndex: repo.frequencyIndex,
      accuracyIndex: repo.accuracyIndex,
      operateInBackground: repo.operateInBackground,
      sendInOneTransmission: repo.sendInOneTransmission,
      highContrast: repo.highContrast,
      trueNorth: repo.trueNorth,
      operateWhenTerminated: repo.operateWhenTerminated,
      disableWhenStatic: repo.disableWhenStatic,
      displayDecimalMinutes: repo.displayDecimalMinutes,
      passwordHash: repo.passwordHash,
      targetIpAddress: repo.targetIpAddress,
      targetPort: repo.targetPort,
      multicastGroupAddress: repo.multicastGroupAddress,
      socketPort: repo.socketPort,
      taipDeviceId: repo.taipDeviceId,
      bleEnabled: repo.bleEnabled,
      bleDeviceName: repo.bleDeviceName,
      customGptxt: repo.customGptxt,
      websocketPort: repo.websocketPort,
      websocketUrl: repo.websocketUrl,
      staticThresholdMeters: repo.staticThresholdMeters,
      speedUnitIndex: repo.speedUnitIndex,
      ggaEnabled: repo.ggaEnabled,
      gllEnabled: repo.gllEnabled,
      gsaEnabled: repo.gsaEnabled,
      hdgEnabled: repo.hdgEnabled,
      hdmEnabled: repo.hdmEnabled,
      hdtEnabled: repo.hdtEnabled,
      rmcEnabled: repo.rmcEnabled,
      vtgEnabled: repo.vtgEnabled,
      zdaEnabled: repo.zdaEnabled,
      pashrEnabled: repo.pashrEnabled,
      gptxtEnabled: repo.gptxtEnabled,
      taipPvEnabled: repo.taipPvEnabled,
      taipAlEnabled: repo.taipAlEnabled,
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _persist();
  }

  Future<void> updateSingle(AppSettings Function(AppSettings) setter) async {
    state = setter(state);
    await _persist();
  }

  Future<void> _persist() async {
    final repo = ref.read(settingsRepositoryProvider).valueOrNull;
    if (repo == null) {
      // Repository not yet loaded — skip silently but log in debug.
      assert(false, '[AppSettingsNotifier] persist called before repo loaded');
      return;
    }
    try {
      await _saveToRepo(repo, state);
    } catch (e) {
      // Surface the error as a provider error so the UI can react.
      throw StateError('Failed to persist settings: $e');
    }
  }

  static Future<void> _saveToRepo(SettingsRepository repo, AppSettings s) {
    return Future.wait([
      repo.setProtocolIndex(s.protocolIndex),
      repo.setConnectionMethodIndex(s.connectionMethodIndex),
      repo.setNetworkIndex(s.networkIndex),
      repo.setFrequencyIndex(s.frequencyIndex),
      repo.setAccuracyIndex(s.accuracyIndex),
      repo.setOperateInBackground(s.operateInBackground),
      repo.setSendInOneTransmission(s.sendInOneTransmission),
      repo.setHighContrast(s.highContrast),
      repo.setTrueNorth(s.trueNorth),
      repo.setOperateWhenTerminated(s.operateWhenTerminated),
      repo.setDisableWhenStatic(s.disableWhenStatic),
      repo.setDisplayDecimalMinutes(s.displayDecimalMinutes),
      repo.setPasswordHash(s.passwordHash),
      repo.setTargetIpAddress(s.targetIpAddress),
      repo.setTargetPort(s.targetPort),
      repo.setMulticastGroupAddress(s.multicastGroupAddress),
      repo.setSocketPort(s.socketPort),
      repo.setTaipDeviceId(s.taipDeviceId),
      repo.setBleEnabled(s.bleEnabled),
      repo.setBleDeviceName(s.bleDeviceName),
      repo.setCustomGptxt(s.customGptxt),
      repo.setWebsocketPort(s.websocketPort),
      repo.setWebsocketUrl(s.websocketUrl),
      repo.setStaticThresholdMeters(s.staticThresholdMeters),
      repo.setSpeedUnitIndex(s.speedUnitIndex),
      repo.setGgaEnabled(s.ggaEnabled),
      repo.setGllEnabled(s.gllEnabled),
      repo.setGsaEnabled(s.gsaEnabled),
      repo.setHdgEnabled(s.hdgEnabled),
      repo.setHdmEnabled(s.hdmEnabled),
      repo.setHdtEnabled(s.hdtEnabled),
      repo.setRmcEnabled(s.rmcEnabled),
      repo.setVtgEnabled(s.vtgEnabled),
      repo.setZdaEnabled(s.zdaEnabled),
      repo.setPashrEnabled(s.pashrEnabled),
      repo.setGptxtEnabled(s.gptxtEnabled),
      repo.setTaipPvEnabled(s.taipPvEnabled),
      repo.setTaipAlEnabled(s.taipAlEnabled),
    ]);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

/// Whether the settings repository has finished loading.
final settingsReadyProvider = Provider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).hasValue;
});

// ── Connection profiles ───────────────────────────────────────────────────────

class ConnectionProfilesNotifier
    extends Notifier<List<ConnectionProfile>> {
  @override
  List<ConnectionProfile> build() {
    final repoAsync = ref.watch(settingsRepositoryProvider);
    return repoAsync.when(
      data: (repo) => repo.connectionProfiles,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> saveProfile(ConnectionProfile profile) async {
    final existing = List<ConnectionProfile>.from(state);
    final idx = existing.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      existing[idx] = profile;
    } else {
      existing.add(profile);
    }
    state = existing;
    await _persist();
  }

  Future<void> deleteProfile(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final repo = ref.read(settingsRepositoryProvider).valueOrNull;
    if (repo == null) return;
    await repo.setConnectionProfiles(state);
  }
}

final connectionProfilesProvider =
    NotifierProvider<ConnectionProfilesNotifier, List<ConnectionProfile>>(
  ConnectionProfilesNotifier.new,
);

// ── GPS position stream ───────────────────────────────────────────────────────

GpsPosition _positionToGpsPosition(Position p) {
  return GpsPosition(
    latitude: p.latitude,
    longitude: p.longitude,
    altitude: p.altitude,
    speed: p.speed,
    heading: p.heading,
    accuracy: p.accuracy,
    timestamp: p.timestamp,
    hasFix: true,
    verticalAccuracy: p.altitudeAccuracy,
    headingAccuracy: p.headingAccuracy,
  );
}

final locationPermissionErrorProvider = StateProvider<String?>((ref) => null);

/// Raw position stream — no frequency throttling or static filtering.
/// Useful for UI components (map, accuracy dot) that need every update.
final rawPositionStreamProvider = StreamProvider<GpsPosition>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);

  final hasPermission = await locationService.checkAndRequestPermission();
  if (!hasPermission) {
    ref.read(locationPermissionErrorProvider.notifier).state =
        'Location permission denied. Grant access in Settings → JetourGPS → Location.';
    return;
  }

  final isEnabled = await locationService.isLocationServiceEnabled();
  if (!isEnabled) {
    ref.read(locationPermissionErrorProvider.notifier).state =
        'Location services are disabled. Enable in device Settings → Privacy → Location Services.';
    return;
  }

  ref.read(locationPermissionErrorProvider.notifier).state = null;

  final settings = ref.watch(appSettingsProvider);
  final stream = locationService.getPositionStream(
    accuracyPreset: settings.accuracyIndex,
    allowBackgroundLocationUpdates: settings.operateInBackground,
  );

  await for (final position in stream) {
    yield _positionToGpsPosition(position);
  }
});

/// Throttled + static-filtered stream used for transmission.
/// Separate from [rawPositionStreamProvider] so UI consumers are unaffected.
final positionStreamProvider = StreamProvider<GpsPosition>((ref) async* {
  final settings = ref.watch(appSettingsProvider);
  final frequency = TransmissionFrequencyPreset.fromIndex(settings.frequencyIndex);
  final disableWhenStatic = settings.disableWhenStatic;
  final staticThreshold = settings.staticThresholdMeters;

  GpsPosition? lastEmitted;

  await for (final gpsPos in ref.watch(rawPositionStreamProvider.stream)) {
    if (disableWhenStatic && lastEmitted != null) {
      final distance = Geolocator.distanceBetween(
        lastEmitted.latitude,
        lastEmitted.longitude,
        gpsPos.latitude,
        gpsPos.longitude,
      );
      if (distance < staticThreshold) continue;
    }

    if (frequency != Duration.zero) {
      final elapsed = lastEmitted != null
          ? gpsPos.timestamp.difference(lastEmitted.timestamp)
          : frequency;
      if (elapsed < frequency) continue;
    }

    lastEmitted = gpsPos;
    yield gpsPos;
  }
});

// ── Position tracker (last known / previous) ──────────────────────────────────

class _PositionTracker {
  final GpsPosition? previous;
  final GpsPosition? current;

  _PositionTracker({this.previous, this.current});

  _PositionTracker update(GpsPosition pos) =>
      _PositionTracker(previous: current, current: pos);
}

class _PositionTrackerNotifier extends Notifier<_PositionTracker> {
  @override
  _PositionTracker build() {
    // Listen to the raw stream so the displayed position updates immediately,
    // independent of the transmission throttle.
    ref.listen(rawPositionStreamProvider, (_, next) {
      next.whenData((pos) {
        state = state.update(pos);
      });
    });
    return _PositionTracker();
  }
}

final _positionTrackerProvider =
    NotifierProvider<_PositionTrackerNotifier, _PositionTracker>(
  _PositionTrackerNotifier.new,
);

final lastKnownPositionProvider = Provider<GpsPosition?>((ref) {
  return ref.watch(_positionTrackerProvider).current;
});

// ── Network info ─────────────────────────────────────────────────────────────

final networkInfoProvider = FutureProvider<NetworkInfo>((ref) async {
  final netInfo = net_info.NetworkInfo();

  final wifiIp = await netInfo.getWifiIP();

  String? hotspotIp;
  String? hotspotSubnet;
  bool isHotspot = false;

  if (wifiIp != null) {
    isHotspot = _isHotspotIp(wifiIp);
    if (isHotspot) {
      hotspotIp = wifiIp;
      final parts = wifiIp.split('.');
      if (parts.length == 4) {
        hotspotSubnet = '${parts[0]}.${parts[1]}.${parts[2]}.0/24';
      }
    }
  }

  // Attempt to get cellular IP via getWifiBSSID fallback is not reliable;
  // left as null until a platform channel is available.
  return NetworkInfo(
    wifiIp: isHotspot ? null : wifiIp,
    cellularIp: null,
    hotspotIp: hotspotIp,
    hotspotSubnet: hotspotSubnet,
    isHotspotActive: isHotspot,
  );
});

bool _isHotspotIp(String ip) {
  return ip.startsWith('192.168.43.') ||
      ip.startsWith('172.20.') ||
      ip.startsWith('100.64.');
}
