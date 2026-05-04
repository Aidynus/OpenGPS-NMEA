import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/providers/location_provider.dart';
import '../../../domain/models/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _GeneralSection(settings: settings, notifier: notifier),
          const SizedBox(height: 8),
          if (settings.protocolIndex == ProtocolPreset.nmea)
            _NmeaSection(settings: settings, notifier: notifier),
          if (settings.protocolIndex == ProtocolPreset.taip)
            _TaipSection(settings: settings, notifier: notifier),
          const SizedBox(height: 8),
          _ConnectionSection(settings: settings, notifier: notifier),
          const SizedBox(height: 8),
          _NetworkSection(settings: settings, notifier: notifier),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GeneralSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;

  const _GeneralSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('General', style: TextStyle(fontWeight: FontWeight.w600)),
        initiallyExpanded: true,
        children: [
          _DropdownRow<int>(
            label: 'GPS Accuracy',
            value: settings.accuracyIndex,
            items: const [
              DropdownMenuItem(value: GpsAccuracyPreset.best, child: Text('Very Best')),
              DropdownMenuItem(value: GpsAccuracyPreset.good, child: Text('Pretty Good')),
              DropdownMenuItem(value: GpsAccuracyPreset.moderate, child: Text('Moderate')),
              DropdownMenuItem(value: GpsAccuracyPreset.lazy, child: Text('Lazy')),
            ],
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(accuracyIndex: v ?? s.accuracyIndex)),
          ),
          _DropdownRow<int>(
            label: 'Time Between Positions',
            value: settings.frequencyIndex,
            items: const [
              DropdownMenuItem(value: TransmissionFrequencyPreset.noDelay, child: Text('No Delay')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.oneSecond, child: Text('1s')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.fiveSeconds, child: Text('5s')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.thirtySeconds, child: Text('30s')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.sixtySeconds, child: Text('60s')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.fiveMinutes, child: Text('5 Minutes')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.thirtyMinutes, child: Text('30 Minutes')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.oneHour, child: Text('1 Hour')),
            ],
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(frequencyIndex: v ?? s.frequencyIndex)),
          ),
          _SwitchRow(
            label: 'Disable When Static',
            value: settings.disableWhenStatic,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(disableWhenStatic: v)),
          ),
          _DropdownRow<int>(
            label: 'Protocol Type',
            value: settings.protocolIndex,
            items: const [
              DropdownMenuItem(value: ProtocolPreset.nmea, child: Text('NMEA')),
              DropdownMenuItem(value: ProtocolPreset.taip, child: Text('TAIP')),
            ],
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(protocolIndex: v ?? s.protocolIndex)),
          ),
          const Divider(),
          _SwitchRow(
            label: 'Operate in Background Mode',
            value: settings.operateInBackground,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(operateInBackground: v)),
          ),
          _SwitchRow(
            label: 'Send in 1 Transmission',
            value: settings.sendInOneTransmission,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(sendInOneTransmission: v)),
          ),
          _SwitchRow(
            label: 'High Contrast',
            value: settings.highContrast,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(highContrast: v)),
          ),
          _SwitchRow(
            label: 'True North (not Magnetic)',
            value: settings.trueNorth,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(trueNorth: v)),
          ),
          _SwitchRow(
            label: 'Operate When Terminated',
            value: settings.operateWhenTerminated,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(operateWhenTerminated: v)),
          ),
          _SwitchRow(
            label: 'Display Decimal Minutes',
            value: settings.displayDecimalMinutes,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(displayDecimalMinutes: v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Lock with Password'),
                const Spacer(),
                SizedBox(
                  width: 140,
                  child: TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      hintText: 'Password',
                    ),
                    controller: TextEditingController(text: settings.passwordHash ?? ''),
                    onChanged: (v) => notifier.updateSingle((s) => s.copyWith(
                      passwordHash: v.isEmpty ? null : v,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NmeaSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;

  const _NmeaSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('NMEA', style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _SwitchRow(
            label: 'GGA',
            value: settings.ggaEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(ggaEnabled: v)),
          ),
          _SwitchRow(
            label: 'GLL',
            value: settings.gllEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(gllEnabled: v)),
          ),
          _SwitchRow(
            label: 'GSA',
            value: settings.gsaEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(gsaEnabled: v)),
          ),
          _SwitchRow(
            label: 'HDG',
            value: settings.hdgEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(hdgEnabled: v)),
          ),
          _SwitchRow(
            label: 'HDM',
            value: settings.hdmEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(hdmEnabled: v)),
          ),
          _SwitchRow(
            label: 'HDT',
            value: settings.hdtEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(hdtEnabled: v)),
          ),
          _SwitchRow(
            label: 'RMC',
            value: settings.rmcEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(rmcEnabled: v)),
          ),
          _SwitchRow(
            label: 'VTG',
            value: settings.vtgEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(vtgEnabled: v)),
          ),
          _SwitchRow(
            label: 'ZDA',
            value: settings.zdaEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(zdaEnabled: v)),
          ),
          _SwitchRow(
            label: 'PASHR',
            value: settings.pashrEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(pashrEnabled: v)),
          ),
          _SwitchRow(
            label: 'GPTXT',
            value: settings.gptxtEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(gptxtEnabled: v)),
          ),
          if (settings.gptxtEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(' Custom Text'),
                  const Spacer(),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        hintText: 'Device ID',
                      ),
                      controller: TextEditingController(text: settings.customGptxt ?? ''),
                      onChanged: (v) => notifier.updateSingle((s) => s.copyWith(
                        customGptxt: v.isEmpty ? null : v,
                      )),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TaipSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;

  const _TaipSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('TAIP', style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _SwitchRow(
            label: 'PV Message',
            value: settings.taipPvEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(taipPvEnabled: v)),
          ),
          _SwitchRow(
            label: 'AL Message',
            value: settings.taipAlEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(taipAlEnabled: v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Device ID'),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: TextField(
                    maxLength: 4,
                    decoration: const InputDecoration(
                      isDense: true,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    controller: TextEditingController(text: settings.taipDeviceId),
                    onChanged: (v) => notifier.updateSingle((s) => s.copyWith(taipDeviceId: v)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;

  const _ConnectionSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isSocket = settings.connectionMethodIndex == ConnectionMethodPreset.socket;
    final isTcpClient = settings.connectionMethodIndex == ConnectionMethodPreset.tcpClient;
    final isUdpClient = settings.connectionMethodIndex == ConnectionMethodPreset.udpClient;
    final isUdpMulticast = settings.connectionMethodIndex == ConnectionMethodPreset.udpMulticast;
    final isTaipUdp = settings.connectionMethodIndex == ConnectionMethodPreset.taipUdp;
    final isWebSocket = settings.connectionMethodIndex == ConnectionMethodPreset.webSocket;
    final needsTargetIp = isTcpClient || isUdpClient || isTaipUdp;

    return Card(
      child: ExpansionTile(
        title: const Text('Connection Method', style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _RadioRow<int>(
            label: 'Socket',
            value: ConnectionMethodPreset.socket,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          _RadioRow<int>(
            label: 'TCP Client',
            value: ConnectionMethodPreset.tcpClient,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          _RadioRow<int>(
            label: 'UDP Client',
            value: ConnectionMethodPreset.udpClient,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          _RadioRow<int>(
            label: 'UDP Multicast',
            value: ConnectionMethodPreset.udpMulticast,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          _RadioRow<int>(
            label: 'UDP Broadcast',
            value: ConnectionMethodPreset.udpBroadcast,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          _RadioRow<int>(
            label: 'TAIP UDP',
            value: ConnectionMethodPreset.taipUdp,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          _RadioRow<int>(
            label: 'WebSocket',
            value: ConnectionMethodPreset.webSocket,
            groupValue: settings.connectionMethodIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(connectionMethodIndex: v)),
          ),
          const Divider(),
          if (isSocket)
            _NumberFieldRow(
              label: 'Socket Port',
              value: settings.socketPort,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(socketPort: v)),
            ),
          if (needsTargetIp)
            _TextFieldRow(
              label: 'Target IP',
              value: settings.targetIpAddress,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(targetIpAddress: v)),
            ),
          if (needsTargetIp || isSocket)
            _NumberFieldRow(
              label: 'Target Port',
              value: settings.targetPort,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(targetPort: v)),
            ),
          if (isUdpMulticast)
            _TextFieldRow(
              label: 'Group Address',
              value: settings.multicastGroupAddress,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(multicastGroupAddress: v)),
            ),
          if (isWebSocket)
            _TextFieldRow(
              label: 'Server URL',
              value: settings.websocketUrl ?? '',
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(
                websocketUrl: v.isEmpty ? null : v,
              )),
            ),
        ],
      ),
    );
  }
}

class _NetworkSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;

  const _NetworkSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Network', style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _RadioRow<int>(
            label: 'WiFi',
            value: NetworkPreset.wifi,
            groupValue: settings.networkIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(networkIndex: v)),
          ),
          _RadioRow<int>(
            label: 'Cellular',
            value: NetworkPreset.cellular,
            groupValue: settings.networkIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(networkIndex: v)),
          ),
          _RadioRow<int>(
            label: 'Hotspot',
            value: NetworkPreset.hotspot,
            groupValue: settings.networkIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(networkIndex: v)),
          ),
          _RadioRow<int>(
            label: 'BLE',
            value: NetworkPreset.ble,
            groupValue: settings.networkIndex,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(networkIndex: v)),
          ),
          if (settings.networkIndex == NetworkPreset.ble)
            _SwitchRow(
              label: 'BLE Enabled',
              value: settings.bleEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(bleEnabled: v)),
            ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox(),
            isDense: true,
          ),
        ],
      ),
    );
  }
}

class _RadioRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  const _RadioRow({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _TextFieldRow extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TextFieldRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          SizedBox(
            width: 160,
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              controller: TextEditingController(text: value),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberFieldRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberFieldRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              controller: TextEditingController(text: value.toString()),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null) onChanged(parsed);
              },
            ),
          ),
        ],
      ),
    );
  }
}
