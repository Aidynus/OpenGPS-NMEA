import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository._(this._prefs);

  static Future<SettingsRepository> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository._(prefs);
  }

  // Protocol
  int get protocolIndex => _prefs.getInt('protocolIndex') ?? 0;
  Future<bool> setProtocolIndex(int value) =>
      _prefs.setInt('protocolIndex', value);

  // Connection
  int get connectionMethodIndex => _prefs.getInt('connectionMethodIndex') ?? 0;
  Future<bool> setConnectionMethodIndex(int value) =>
      _prefs.setInt('connectionMethodIndex', value);

  // Network
  int get networkIndex => _prefs.getInt('networkIndex') ?? 0;
  Future<bool> setNetworkIndex(int value) =>
      _prefs.setInt('networkIndex', value);

  // Frequency
  int get frequencyIndex => _prefs.getInt('frequencyIndex') ?? 1;
  Future<bool> setFrequencyIndex(int value) =>
      _prefs.setInt('frequencyIndex', value);

  // Accuracy
  int get accuracyIndex => _prefs.getInt('accuracyIndex') ?? 0;
  Future<bool> setAccuracyIndex(int value) =>
      _prefs.setInt('accuracyIndex', value);

  // Boolean settings
  bool get operateInBackground => _prefs.getBool('operateInBackground') ?? true;
  Future<bool> setOperateInBackground(bool value) =>
      _prefs.setBool('operateInBackground', value);

  bool get sendInOneTransmission =>
      _prefs.getBool('sendInOneTransmission') ?? false;
  Future<bool> setSendInOneTransmission(bool value) =>
      _prefs.setBool('sendInOneTransmission', value);

  bool get highContrast => _prefs.getBool('highContrast') ?? false;
  Future<bool> setHighContrast(bool value) =>
      _prefs.setBool('highContrast', value);

  bool get trueNorth => _prefs.getBool('trueNorth') ?? false;
  Future<bool> setTrueNorth(bool value) =>
      _prefs.setBool('trueNorth', value);

  bool get operateWhenTerminated =>
      _prefs.getBool('operateWhenTerminated') ?? false;
  Future<bool> setOperateWhenTerminated(bool value) =>
      _prefs.setBool('operateWhenTerminated', value);

  bool get disableWhenStatic => _prefs.getBool('disableWhenStatic') ?? false;
  Future<bool> setDisableWhenStatic(bool value) =>
      _prefs.setBool('disableWhenStatic', value);

  bool get displayDecimalMinutes =>
      _prefs.getBool('displayDecimalMinutes') ?? false;
  Future<bool> setDisplayDecimalMinutes(bool value) =>
      _prefs.setBool('displayDecimalMinutes', value);

  // Authentication
  String? get passwordHash => _prefs.getString('passwordHash');
  Future<bool> setPasswordHash(String? value) =>
      value == null ? _prefs.remove('passwordHash') : _prefs.setString('passwordHash', value);

  // Network targets
  String get targetIpAddress =>
      _prefs.getString('targetIpAddress') ?? '192.168.1.100';
  Future<bool> setTargetIpAddress(String value) =>
      _prefs.setString('targetIpAddress', value);

  int get targetPort => _prefs.getInt('targetPort') ?? 11123;
  Future<bool> setTargetPort(int value) =>
      _prefs.setInt('targetPort', value);

  String get multicastGroupAddress =>
      _prefs.getString('multicastGroupAddress') ?? '239.192.1.1';
  Future<bool> setMulticastGroupAddress(String value) =>
      _prefs.setString('multicastGroupAddress', value);

  int get socketPort => _prefs.getInt('socketPort') ?? 11123;
  Future<bool> setSocketPort(int value) =>
      _prefs.setInt('socketPort', value);

  int get websocketPort => _prefs.getInt('websocketPort') ?? 8080;
  Future<bool> setWebsocketPort(int value) =>
      _prefs.setInt('websocketPort', value);

  String? get websocketUrl => _prefs.getString('websocketUrl');
  Future<bool> setWebsocketUrl(String? value) =>
      value == null ? _prefs.remove('websocketUrl') : _prefs.setString('websocketUrl', value);

  // TAIP
  String get taipDeviceId => _prefs.getString('taipDeviceId') ?? 'D001';
  Future<bool> setTaipDeviceId(String value) =>
      _prefs.setString('taipDeviceId', value);

  bool get taipPvEnabled => _prefs.getBool('taipPvEnabled') ?? true;
  Future<bool> setTaipPvEnabled(bool value) =>
      _prefs.setBool('taipPvEnabled', value);

  bool get taipAlEnabled => _prefs.getBool('taipAlEnabled') ?? true;
  Future<bool> setTaipAlEnabled(bool value) =>
      _prefs.setBool('taipAlEnabled', value);

  // BLE
  bool get bleEnabled => _prefs.getBool('bleEnabled') ?? false;
  Future<bool> setBleEnabled(bool value) =>
      _prefs.setBool('bleEnabled', value);

  // Custom GPTXT
  String? get customGptxt => _prefs.getString('customGptxt');
  Future<bool> setCustomGptxt(String? value) =>
      value == null ? _prefs.remove('customGptxt') : _prefs.setString('customGptxt', value);

  // Static threshold
  double get staticThresholdMeters =>
      _prefs.getDouble('staticThresholdMeters') ?? 1.5;
  Future<bool> setStaticThresholdMeters(double value) =>
      _prefs.setDouble('staticThresholdMeters', value);

  // NMEA message toggles
  bool get ggaEnabled => _prefs.getBool('ggaEnabled') ?? false;
  Future<bool> setGgaEnabled(bool value) =>
      _prefs.setBool('ggaEnabled', value);

  bool get gllEnabled => _prefs.getBool('gllEnabled') ?? false;
  Future<bool> setGllEnabled(bool value) =>
      _prefs.setBool('gllEnabled', value);

  bool get gsaEnabled => _prefs.getBool('gsaEnabled') ?? false;
  Future<bool> setGsaEnabled(bool value) =>
      _prefs.setBool('gsaEnabled', value);

  bool get hdgEnabled => _prefs.getBool('hdgEnabled') ?? false;
  Future<bool> setHdgEnabled(bool value) =>
      _prefs.setBool('hdgEnabled', value);

  bool get hdmEnabled => _prefs.getBool('hdmEnabled') ?? false;
  Future<bool> setHdmEnabled(bool value) =>
      _prefs.setBool('hdmEnabled', value);

  bool get hdtEnabled => _prefs.getBool('hdtEnabled') ?? false;
  Future<bool> setHdtEnabled(bool value) =>
      _prefs.setBool('hdtEnabled', value);

  bool get rmcEnabled => _prefs.getBool('rmcEnabled') ?? true;
  Future<bool> setRmcEnabled(bool value) =>
      _prefs.setBool('rmcEnabled', value);

  bool get vtgEnabled => _prefs.getBool('vtgEnabled') ?? false;
  Future<bool> setVtgEnabled(bool value) =>
      _prefs.setBool('vtgEnabled', value);

  bool get zdaEnabled => _prefs.getBool('zdaEnabled') ?? false;
  Future<bool> setZdaEnabled(bool value) =>
      _prefs.setBool('zdaEnabled', value);

  bool get pashrEnabled => _prefs.getBool('pashrEnabled') ?? false;
  Future<bool> setPashrEnabled(bool value) =>
      _prefs.setBool('pashrEnabled', value);

  bool get gptxtEnabled => _prefs.getBool('gptxtEnabled') ?? false;
  Future<bool> setGptxtEnabled(bool value) =>
      _prefs.setBool('gptxtEnabled', value);

  // Reset all keys to their defaults
  Future<bool> resetToDefaults() async {
    final results = await Future.wait([
      setProtocolIndex(0),
      setConnectionMethodIndex(0),
      setNetworkIndex(0),
      setFrequencyIndex(1),
      setAccuracyIndex(0),
      setOperateInBackground(true),
      setSendInOneTransmission(false),
      setHighContrast(false),
      setTrueNorth(false),
      setOperateWhenTerminated(false),
      setDisableWhenStatic(false),
      setDisplayDecimalMinutes(false),
      setPasswordHash(null),
      setTargetIpAddress('192.168.1.100'),
      setTargetPort(11123),
      setMulticastGroupAddress('239.192.1.1'),
      setSocketPort(11123),
      setWebsocketPort(8080),
      setWebsocketUrl(null),
      setTaipDeviceId('D001'),
      setTaipPvEnabled(true),
      setTaipAlEnabled(true),
      setBleEnabled(false),
      setCustomGptxt(null),
      setStaticThresholdMeters(1.5),
      setGgaEnabled(false),
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
    ]);
    return results.every((r) => r);
  }

  Future<bool> clearAll() => _prefs.clear();
}