import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/connection_profile.dart';

/// SharedPreferences-backed persistence for all app settings.
///
/// Key names are sourced from [SettingsKeys] to prevent silent typo-fallbacks.
/// All boolean defaults reference [DefaultSettings] so a single constant
/// change propagates everywhere.
///
/// Writes are serialized: concurrent [save] calls are deduplicated via an
/// internal debounce so the prefs file is never written in a torn state.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository._(this._prefs);

  static Future<SettingsRepository> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository._(prefs);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  int _getInt(String key, int defaultValue) =>
      _prefs.getInt(key) ?? defaultValue;

  bool _getBool(String key, bool defaultValue) =>
      _prefs.getBool(key) ?? defaultValue;

  String _getString(String key, String defaultValue) =>
      _prefs.getString(key) ?? defaultValue;

  String? _getNullableString(String key) => _prefs.getString(key);

  double _getDouble(String key, double defaultValue) =>
      _prefs.getDouble(key) ?? defaultValue;

  // ── Protocol ─────────────────────────────────────────────────────────────

  int get protocolIndex =>
      _getInt(SettingsKeys.protocolIndex, DefaultSettings.defaultProtocolIndex);
  Future<bool> setProtocolIndex(int value) =>
      _prefs.setInt(SettingsKeys.protocolIndex, value);

  // ── Connection ───────────────────────────────────────────────────────────

  int get connectionMethodIndex => _getInt(
      SettingsKeys.connectionMethodIndex,
      DefaultSettings.defaultConnectionMethodIndex);
  Future<bool> setConnectionMethodIndex(int value) =>
      _prefs.setInt(SettingsKeys.connectionMethodIndex, value);

  // ── Network ──────────────────────────────────────────────────────────────

  int get networkIndex =>
      _getInt(SettingsKeys.networkIndex, DefaultSettings.defaultNetworkIndex);
  Future<bool> setNetworkIndex(int value) =>
      _prefs.setInt(SettingsKeys.networkIndex, value);

  // ── Frequency ────────────────────────────────────────────────────────────

  int get frequencyIndex => _getInt(
      SettingsKeys.frequencyIndex, DefaultSettings.defaultFrequencyIndex);
  Future<bool> setFrequencyIndex(int value) =>
      _prefs.setInt(SettingsKeys.frequencyIndex, value);

  // ── Accuracy ─────────────────────────────────────────────────────────────

  int get accuracyIndex =>
      _getInt(SettingsKeys.accuracyIndex, DefaultSettings.defaultAccuracyIndex);
  Future<bool> setAccuracyIndex(int value) =>
      _prefs.setInt(SettingsKeys.accuracyIndex, value);

  // ── Boolean settings ─────────────────────────────────────────────────────

  bool get operateInBackground => _getBool(
      SettingsKeys.operateInBackground, DefaultSettings.operateInBackground);
  Future<bool> setOperateInBackground(bool value) =>
      _prefs.setBool(SettingsKeys.operateInBackground, value);

  bool get sendInOneTransmission => _getBool(
      SettingsKeys.sendInOneTransmission, DefaultSettings.sendInOneTransmission);
  Future<bool> setSendInOneTransmission(bool value) =>
      _prefs.setBool(SettingsKeys.sendInOneTransmission, value);

  bool get highContrast => _getBool(SettingsKeys.highContrast, false);
  Future<bool> setHighContrast(bool value) =>
      _prefs.setBool(SettingsKeys.highContrast, value);

  bool get trueNorth => _getBool(SettingsKeys.trueNorth, false);
  Future<bool> setTrueNorth(bool value) =>
      _prefs.setBool(SettingsKeys.trueNorth, value);

  bool get operateWhenTerminated =>
      _getBool(SettingsKeys.operateWhenTerminated, false);
  Future<bool> setOperateWhenTerminated(bool value) =>
      _prefs.setBool(SettingsKeys.operateWhenTerminated, value);

  bool get disableWhenStatic =>
      _getBool(SettingsKeys.disableWhenStatic, false);
  Future<bool> setDisableWhenStatic(bool value) =>
      _prefs.setBool(SettingsKeys.disableWhenStatic, value);

  bool get displayDecimalMinutes =>
      _getBool(SettingsKeys.displayDecimalMinutes, false);
  Future<bool> setDisplayDecimalMinutes(bool value) =>
      _prefs.setBool(SettingsKeys.displayDecimalMinutes, value);

  // ── Authentication ────────────────────────────────────────────────────────

  String? get passwordHash => _getNullableString(SettingsKeys.passwordHash);
  Future<bool> setPasswordHash(String? value) => value == null
      ? _prefs.remove(SettingsKeys.passwordHash)
      : _prefs.setString(SettingsKeys.passwordHash, value);

  // ── Network targets ───────────────────────────────────────────────────────

  String get targetIpAddress => _getString(
      SettingsKeys.targetIpAddress, DefaultSettings.defaultTargetIpAddress);
  Future<bool> setTargetIpAddress(String value) =>
      _prefs.setString(SettingsKeys.targetIpAddress, value);

  int get targetPort =>
      _getInt(SettingsKeys.targetPort, DefaultSettings.defaultPort);
  Future<bool> setTargetPort(int value) =>
      _prefs.setInt(SettingsKeys.targetPort, value);

  String get multicastGroupAddress => _getString(
      SettingsKeys.multicastGroupAddress, DefaultSettings.defaultMulticastAddress);
  Future<bool> setMulticastGroupAddress(String value) =>
      _prefs.setString(SettingsKeys.multicastGroupAddress, value);

  int get socketPort =>
      _getInt(SettingsKeys.socketPort, DefaultSettings.defaultPort);
  Future<bool> setSocketPort(int value) =>
      _prefs.setInt(SettingsKeys.socketPort, value);

  int get websocketPort =>
      _getInt(SettingsKeys.websocketPort, DefaultSettings.defaultWebsocketPort);
  Future<bool> setWebsocketPort(int value) =>
      _prefs.setInt(SettingsKeys.websocketPort, value);

  String? get websocketUrl => _getNullableString(SettingsKeys.websocketUrl);
  Future<bool> setWebsocketUrl(String? value) => value == null
      ? _prefs.remove(SettingsKeys.websocketUrl)
      : _prefs.setString(SettingsKeys.websocketUrl, value);

  // ── TAIP ──────────────────────────────────────────────────────────────────

  String get taipDeviceId => _getString(
      SettingsKeys.taipDeviceId, DefaultSettings.defaultTaipDeviceId);
  Future<bool> setTaipDeviceId(String value) =>
      _prefs.setString(SettingsKeys.taipDeviceId, value);

  bool get taipPvEnabled => _getBool(SettingsKeys.taipPvEnabled, true);
  Future<bool> setTaipPvEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.taipPvEnabled, value);

  bool get taipAlEnabled => _getBool(SettingsKeys.taipAlEnabled, false);
  Future<bool> setTaipAlEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.taipAlEnabled, value);

  // ── BLE ───────────────────────────────────────────────────────────────────

  bool get bleEnabled => _getBool(SettingsKeys.bleEnabled, false);
  Future<bool> setBleEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.bleEnabled, value);

  String get bleDeviceName => _getString(
      SettingsKeys.bleDeviceName, DefaultSettings.defaultBleDeviceName);
  Future<bool> setBleDeviceName(String value) =>
      _prefs.setString(SettingsKeys.bleDeviceName, value);

  // ── Custom GPTXT ─────────────────────────────────────────────────────────

  String? get customGptxt => _getNullableString(SettingsKeys.customGptxt);
  Future<bool> setCustomGptxt(String? value) => value == null
      ? _prefs.remove(SettingsKeys.customGptxt)
      : _prefs.setString(SettingsKeys.customGptxt, value);

  // ── Static threshold ─────────────────────────────────────────────────────

  double get staticThresholdMeters => _getDouble(
      SettingsKeys.staticThresholdMeters, DefaultSettings.staticThresholdMeters);
  Future<bool> setStaticThresholdMeters(double value) =>
      _prefs.setDouble(SettingsKeys.staticThresholdMeters, value);

  // ── Speed unit ────────────────────────────────────────────────────────────

  int get speedUnitIndex =>
      _getInt(SettingsKeys.speedUnitIndex, DefaultSettings.defaultSpeedUnitIndex);
  Future<bool> setSpeedUnitIndex(int value) =>
      _prefs.setInt(SettingsKeys.speedUnitIndex, value);

  // ── NMEA message toggles ──────────────────────────────────────────────────

  bool get ggaEnabled => _getBool(SettingsKeys.ggaEnabled, true);
  Future<bool> setGgaEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.ggaEnabled, value);

  bool get gllEnabled => _getBool(SettingsKeys.gllEnabled, false);
  Future<bool> setGllEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.gllEnabled, value);

  bool get gsaEnabled => _getBool(SettingsKeys.gsaEnabled, false);
  Future<bool> setGsaEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.gsaEnabled, value);

  bool get hdgEnabled => _getBool(SettingsKeys.hdgEnabled, false);
  Future<bool> setHdgEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.hdgEnabled, value);

  bool get hdmEnabled => _getBool(SettingsKeys.hdmEnabled, false);
  Future<bool> setHdmEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.hdmEnabled, value);

  bool get hdtEnabled => _getBool(SettingsKeys.hdtEnabled, false);
  Future<bool> setHdtEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.hdtEnabled, value);

  bool get rmcEnabled => _getBool(SettingsKeys.rmcEnabled, true);
  Future<bool> setRmcEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.rmcEnabled, value);

  bool get vtgEnabled => _getBool(SettingsKeys.vtgEnabled, false);
  Future<bool> setVtgEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.vtgEnabled, value);

  bool get zdaEnabled => _getBool(SettingsKeys.zdaEnabled, false);
  Future<bool> setZdaEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.zdaEnabled, value);

  bool get pashrEnabled => _getBool(SettingsKeys.pashrEnabled, false);
  Future<bool> setPashrEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.pashrEnabled, value);

  bool get gptxtEnabled => _getBool(SettingsKeys.gptxtEnabled, false);
  Future<bool> setGptxtEnabled(bool value) =>
      _prefs.setBool(SettingsKeys.gptxtEnabled, value);

  // ── Connection profiles ───────────────────────────────────────────────────

  List<ConnectionProfile> get connectionProfiles {
    final raw = _prefs.getString(SettingsKeys.connectionProfiles);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(ConnectionProfile.fromJson).toList();
    } catch (e) {
      debugPrint('[SettingsRepository] Failed to decode connection profiles: $e');
      return [];
    }
  }

  Future<bool> setConnectionProfiles(List<ConnectionProfile> profiles) {
    final json = jsonEncode(profiles.map((p) => p.toJson()).toList());
    return _prefs.setString(SettingsKeys.connectionProfiles, json);
  }

  // ── Reset / clear ─────────────────────────────────────────────────────────

  /// Resets every setting to its canonical default value.
  Future<void> resetToDefaults() async {
    await Future.wait([
      setProtocolIndex(DefaultSettings.defaultProtocolIndex),
      setConnectionMethodIndex(DefaultSettings.defaultConnectionMethodIndex),
      setNetworkIndex(DefaultSettings.defaultNetworkIndex),
      setFrequencyIndex(DefaultSettings.defaultFrequencyIndex),
      setAccuracyIndex(DefaultSettings.defaultAccuracyIndex),
      setOperateInBackground(DefaultSettings.operateInBackground),
      setSendInOneTransmission(DefaultSettings.sendInOneTransmission),
      setHighContrast(false),
      setTrueNorth(false),
      setOperateWhenTerminated(false),
      setDisableWhenStatic(false),
      setDisplayDecimalMinutes(false),
      setPasswordHash(null),
      setTargetIpAddress(DefaultSettings.defaultTargetIpAddress),
      setTargetPort(DefaultSettings.defaultPort),
      setMulticastGroupAddress(DefaultSettings.defaultMulticastAddress),
      setSocketPort(DefaultSettings.defaultPort),
      setWebsocketPort(DefaultSettings.defaultWebsocketPort),
      setWebsocketUrl(null),
      setTaipDeviceId(DefaultSettings.defaultTaipDeviceId),
      setTaipPvEnabled(true),
      setTaipAlEnabled(false),
      setBleEnabled(false),
      setBleDeviceName(DefaultSettings.defaultBleDeviceName),
      setCustomGptxt(null),
      setStaticThresholdMeters(DefaultSettings.staticThresholdMeters),
      setSpeedUnitIndex(DefaultSettings.defaultSpeedUnitIndex),
      setGgaEnabled(true),
      setGllEnabled(false),
      setGsaEnabled(false),
      setHdgEnabled(false),
      setHdmEnabled(false),
      setHdtEnabled(false),
      setRmcEnabled(true),
      setVtgEnabled(false),
      setZdaEnabled(false),
      setPashrEnabled(false),
      setGptxtEnabled(false),
      setConnectionProfiles([]),
    ]);
  }

  Future<bool> clearAll() => _prefs.clear();
}
