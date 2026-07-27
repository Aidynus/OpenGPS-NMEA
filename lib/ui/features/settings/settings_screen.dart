import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/password_hasher.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/location_provider.dart';
import '../../../domain/models/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Connection profiles',
            onPressed: () => context.push('/profiles'),
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GeneralSection(settings: settings, notifier: notifier),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: Durations.short4,
            child: settings.protocolIndex == ProtocolPreset.nmea
                ? _NmeaSection(
                    key: const ValueKey('nmea'),
                    settings: settings,
                    notifier: notifier)
                : settings.protocolIndex == ProtocolPreset.taip
                    ? _TaipSection(
                        key: const ValueKey('taip'),
                        settings: settings,
                        notifier: notifier)
                    : const SizedBox.shrink(key: ValueKey('none')),
          ),
          const SizedBox(height: 12),
          _ConnectionSection(settings: settings, notifier: notifier),
          const SizedBox(height: 12),
          _NetworkSection(settings: settings, notifier: notifier),
          const SizedBox(height: 12),
          _SecuritySection(settings: settings, notifier: notifier),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all settings?'),
        content: const Text(
            'All settings will be returned to their defaults. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(settingsRepositoryProvider).valueOrNull;
      if (repo != null) {
        await repo.resetToDefaults();
        ref
            .read(appSettingsProvider.notifier)
            .updateSettings(AppSettings.defaults());
      }
    }
  }
}

// ── General section ───────────────────────────────────────────────────────────

class _GeneralSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _GeneralSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('General',
            style: TextStyle(fontWeight: FontWeight.w600)),
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
            onChanged: (v) => notifier.updateSingle(
                (s) => s.copyWith(accuracyIndex: v ?? s.accuracyIndex)),
          ),
          _DropdownRow<int>(
            label: 'Update Frequency',
            value: settings.frequencyIndex,
            items: const [
              DropdownMenuItem(value: TransmissionFrequencyPreset.noDelay, child: Text('No Delay')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.oneSecond, child: Text('1 second')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.fiveSeconds, child: Text('5 seconds')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.thirtySeconds, child: Text('30 seconds')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.sixtySeconds, child: Text('1 minute')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.fiveMinutes, child: Text('5 minutes')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.thirtyMinutes, child: Text('30 minutes')),
              DropdownMenuItem(value: TransmissionFrequencyPreset.oneHour, child: Text('1 hour')),
            ],
            onChanged: (v) => notifier.updateSingle(
                (s) => s.copyWith(frequencyIndex: v ?? s.frequencyIndex)),
          ),
          _DropdownRow<int>(
            label: 'Protocol',
            value: settings.protocolIndex,
            items: const [
              DropdownMenuItem(value: ProtocolPreset.nmea, child: Text('NMEA 0183')),
              DropdownMenuItem(value: ProtocolPreset.taip, child: Text('TAIP')),
            ],
            onChanged: (v) => notifier.updateSingle(
                (s) => s.copyWith(protocolIndex: v ?? s.protocolIndex)),
          ),
          _DropdownRow<int>(
            label: 'Speed Unit',
            value: settings.speedUnitIndex,
            items: const [
              DropdownMenuItem(value: SpeedUnitPreset.knots, child: Text('Knots')),
              DropdownMenuItem(value: SpeedUnitPreset.kmh, child: Text('km/h')),
              DropdownMenuItem(value: SpeedUnitPreset.mph, child: Text('mph')),
              DropdownMenuItem(value: SpeedUnitPreset.ms, child: Text('m/s')),
            ],
            onChanged: (v) => notifier.updateSingle(
                (s) => s.copyWith(speedUnitIndex: v ?? s.speedUnitIndex)),
          ),
          const Divider(),
          _SwitchRow(
            label: 'Operate in Background',
            value: settings.operateInBackground,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(operateInBackground: v)),
          ),
          _SwitchRow(
            label: 'Bundle into 1 Transmission',
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
          _SwitchRow(
            label: 'Disable When Static',
            value: settings.disableWhenStatic,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(disableWhenStatic: v)),
          ),
          AnimatedSwitcher(
            duration: Durations.short4,
            child: settings.disableWhenStatic
                ? _StaticThresholdSlider(
                    key: const ValueKey('static-slider'),
                    value: settings.staticThresholdMeters,
                    onChanged: (v) => notifier.updateSingle(
                        (s) => s.copyWith(staticThresholdMeters: v)),
                  )
                : const SizedBox.shrink(key: ValueKey('static-slider-hidden')),
          ),
        ],
      ),
    );
  }
}

// ── Static threshold slider ───────────────────────────────────────────────────

class _StaticThresholdSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _StaticThresholdSlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Static Threshold',
                  style: TextStyle(fontSize: 14)),
              Text('${value.toStringAsFixed(1)} m',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Slider(
            value: value.clamp(0.5, 50.0),
            min: 0.5,
            max: 50.0,
            divisions: 99,
            label: '${value.toStringAsFixed(1)} m',
            onChanged: (v) => onChanged(double.parse(v.toStringAsFixed(1))),
          ),
        ],
      ),
    );
  }
}

// ── NMEA section ──────────────────────────────────────────────────────────────

class _NmeaSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _NmeaSection({super.key, required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('NMEA Messages',
            style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _SwitchRow(label: 'GGA  (Fix data)', value: settings.ggaEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(ggaEnabled: v))),
          _SwitchRow(label: 'GLL  (Lat/Lon)', value: settings.gllEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(gllEnabled: v))),
          _SwitchRow(label: 'GSA  (DOP + Sats)', value: settings.gsaEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(gsaEnabled: v))),
          _SwitchRow(label: 'HDG  (Mag heading)', value: settings.hdgEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(hdgEnabled: v))),
          _SwitchRow(label: 'HDM  (Mag heading simple)', value: settings.hdmEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(hdmEnabled: v))),
          _SwitchRow(label: 'HDT  (True heading)', value: settings.hdtEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(hdtEnabled: v))),
          _SwitchRow(label: 'RMC  (Recommended minimum)', value: settings.rmcEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(rmcEnabled: v))),
          _SwitchRow(label: 'VTG  (Speed/Track)', value: settings.vtgEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(vtgEnabled: v))),
          _SwitchRow(label: 'ZDA  (Date/Time)', value: settings.zdaEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(zdaEnabled: v))),
          _SwitchRow(label: 'PASHR  (Ashtech attitude)', value: settings.pashrEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(pashrEnabled: v))),
          _SwitchRow(label: 'GPTXT  (Custom text)', value: settings.gptxtEnabled,
              onChanged: (v) => notifier.updateSingle((s) => s.copyWith(gptxtEnabled: v))),
          AnimatedSwitcher(
            duration: Durations.short4,
            child: settings.gptxtEnabled
                ? _TextFieldRow(
                    key: const ValueKey('gptxt'),
                    label: 'GPTXT Text',
                    value: settings.customGptxt ?? '',
                    onChanged: (v) => notifier.updateSingle(
                        (s) => s.copyWith(customGptxt: v.isEmpty ? null : v)),
                  )
                : const SizedBox.shrink(key: ValueKey('gptxt-hidden')),
          ),
        ],
      ),
    );
  }
}

// ── TAIP section ──────────────────────────────────────────────────────────────

class _TaipSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _TaipSection({super.key, required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('TAIP Messages',
            style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _SwitchRow(
            label: 'PV  (Position/Velocity)',
            value: settings.taipPvEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(taipPvEnabled: v)),
          ),
          _SwitchRow(
            label: 'AL  (Altitude)',
            value: settings.taipAlEnabled,
            onChanged: (v) => notifier.updateSingle((s) => s.copyWith(taipAlEnabled: v)),
          ),
          _ValidatedTextFieldRow(
            label: 'Device ID',
            value: settings.taipDeviceId,
            validator: validateTaipDeviceId,
            onChanged: (v) =>
                notifier.updateSingle((s) => s.copyWith(taipDeviceId: v)),
          ),
        ],
      ),
    );
  }
}

// ── Connection section ────────────────────────────────────────────────────────

class _ConnectionSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _ConnectionSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final m = settings.connectionMethodIndex;
    final isSocket = m == ConnectionMethodPreset.socket;
    final isTcpClient = m == ConnectionMethodPreset.tcpClient;
    final isUdpClient = m == ConnectionMethodPreset.udpClient;
    final isUdpMulticast = m == ConnectionMethodPreset.udpMulticast;
    final isTaipUdp = m == ConnectionMethodPreset.taipUdp;
    final isWebSocket = m == ConnectionMethodPreset.webSocket;
    final needsTarget = isTcpClient || isUdpClient || isTaipUdp;

    return Card(
      child: ExpansionTile(
        title: const Text('Connection',
            style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          for (final entry in [
            (ConnectionMethodPreset.socket, 'Socket (TCP Server)'),
            (ConnectionMethodPreset.tcpClient, 'TCP Client'),
            (ConnectionMethodPreset.udpClient, 'UDP Unicast'),
            (ConnectionMethodPreset.udpMulticast, 'UDP Multicast'),
            (ConnectionMethodPreset.udpBroadcast, 'UDP Broadcast'),
            (ConnectionMethodPreset.taipUdp, 'TAIP UDP'),
            (ConnectionMethodPreset.webSocket, 'WebSocket'),
          ])
            _RadioRow<int>(
              label: entry.$2,
              value: entry.$1,
              groupValue: settings.connectionMethodIndex,
              onChanged: (v) => notifier.updateSingle(
                  (s) => s.copyWith(connectionMethodIndex: v)),
            ),
          const Divider(),
          if (isSocket)
            _ValidatedNumberFieldRow(
              key: const ValueKey('socket-port'),
              label: 'Socket Port',
              value: settings.socketPort,
              validator: (v) => validatePort(v?.toString()),
              onChanged: (v) =>
                  notifier.updateSingle((s) => s.copyWith(socketPort: v)),
            ),
          if (needsTarget) ...[
            _ValidatedTextFieldRow(
              key: const ValueKey('target-ip'),
              label: 'Target IP',
              value: settings.targetIpAddress,
              validator: validateIpAddress,
              onChanged: (v) =>
                  notifier.updateSingle((s) => s.copyWith(targetIpAddress: v)),
            ),
            _ValidatedNumberFieldRow(
              key: const ValueKey('target-port'),
              label: 'Target Port',
              value: settings.targetPort,
              validator: (v) => validatePort(v?.toString()),
              onChanged: (v) =>
                  notifier.updateSingle((s) => s.copyWith(targetPort: v)),
            ),
          ],
          if (isUdpMulticast)
            _ValidatedTextFieldRow(
              key: const ValueKey('multicast-group'),
              label: 'Multicast Group',
              value: settings.multicastGroupAddress,
              validator: validateMulticastAddress,
              onChanged: (v) => notifier.updateSingle(
                  (s) => s.copyWith(multicastGroupAddress: v)),
            ),
          if (isWebSocket) ...[
            _ValidatedTextFieldRow(
              key: const ValueKey('ws-url'),
              label: 'WebSocket URL',
              value: settings.websocketUrl ?? '',
              hint: 'ws://192.168.1.100:8080',
              validator: validateWebSocketUrl,
              onChanged: (v) => notifier.updateSingle(
                  (s) => s.copyWith(websocketUrl: v.isEmpty ? null : v)),
            ),
            _ValidatedNumberFieldRow(
              key: const ValueKey('ws-port'),
              label: 'WebSocket Port',
              value: settings.websocketPort,
              validator: (v) => validatePort(v?.toString()),
              onChanged: (v) =>
                  notifier.updateSingle((s) => s.copyWith(websocketPort: v)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Network section ───────────────────────────────────────────────────────────

class _NetworkSection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _NetworkSection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Network Interface',
            style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          for (final entry in [
            (NetworkPreset.wifi, 'WiFi'),
            (NetworkPreset.cellular, 'Cellular'),
            (NetworkPreset.hotspot, 'Hotspot'),
            (NetworkPreset.ble, 'Bluetooth LE'),
          ])
            _RadioRow<int>(
              label: entry.$2,
              value: entry.$1,
              groupValue: settings.networkIndex,
              onChanged: (v) =>
                  notifier.updateSingle((s) => s.copyWith(networkIndex: v)),
            ),
          AnimatedSwitcher(
            duration: Durations.short4,
            child: settings.networkIndex == NetworkPreset.ble
                ? Column(
                    key: const ValueKey('ble-options'),
                    children: [
                      _SwitchRow(
                        label: 'BLE Enabled',
                        value: settings.bleEnabled,
                        onChanged: (v) => notifier.updateSingle(
                            (s) => s.copyWith(bleEnabled: v)),
                      ),
                      if (settings.bleEnabled)
                        _TextFieldRow(
                          label: 'BLE Device Name',
                          value: settings.bleDeviceName,
                          onChanged: (v) => notifier.updateSingle(
                              (s) => s.copyWith(bleDeviceName: v)),
                        ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('ble-hidden')),
          ),
        ],
      ),
    );
  }
}

// ── Security section ──────────────────────────────────────────────────────────

class _SecuritySection extends StatelessWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _SecuritySection({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Security',
            style: TextStyle(fontWeight: FontWeight.w600)),
        children: [
          _PasswordSettingRow(settings: settings, notifier: notifier),
        ],
      ),
    );
  }
}

class _PasswordSettingRow extends StatefulWidget {
  final AppSettings settings;
  final AppSettingsNotifier notifier;
  const _PasswordSettingRow({required this.settings, required this.notifier});

  @override
  State<_PasswordSettingRow> createState() => _PasswordSettingRowState();
}

class _PasswordSettingRowState extends State<_PasswordSettingRow> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      widget.notifier
          .updateSingle((s) => s.copyWith(passwordHash: null));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lock removed')),
      );
    } else {
      final hash = hashPassword(raw);
      widget.notifier
          .updateSingle((s) => s.copyWith(passwordHash: hash));
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lock set')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.settings.passwordHash != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isLocked ? Icons.lock : Icons.lock_open,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(isLocked ? 'Settings locked' : 'Settings unlocked',
                  style: const TextStyle(fontSize: 14)),
              const Spacer(),
              if (isLocked)
                TextButton(
                  onPressed: () => widget.notifier.updateSingle(
                      (s) => s.copyWith(passwordHash: null)),
                  child: const Text('Remove Lock'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: isLocked ? 'Change password' : 'Set password',
                    hintText: isLocked ? 'Enter new password' : 'Enter password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(onPressed: _save, child: const Text('Set')),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable setting row widgets ──────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (v) {
        HapticFeedback.lightImpact();
        onChanged(v);
      },
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
  const _DropdownRow({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          DropdownButton<T>(
            value: value,
            items: items,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
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
  const _RadioRow({super.key, required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) {
          HapticFeedback.lightImpact();
          onChanged(v);
        }
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

/// A text field row that validates its content before saving.
class _ValidatedTextFieldRow extends StatefulWidget {
  final String label;
  final String value;
  final String? hint;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  const _ValidatedTextFieldRow({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    required this.validator,
    required this.onChanged,
  });

  @override
  State<_ValidatedTextFieldRow> createState() => _ValidatedTextFieldRowState();
}

class _ValidatedTextFieldRowState extends State<_ValidatedTextFieldRow> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ValidatedTextFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_controller.selection.isValid) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(widget.label,
                style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                errorText: _error,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
              ),
              onChanged: (v) {
                final err = widget.validator(v);
                setState(() => _error = err);
                if (err == null) widget.onChanged(v);
              },
              onEditingComplete: () {
                final err = widget.validator(_controller.text);
                setState(() => _error = err);
                if (err == null) widget.onChanged(_controller.text);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A validated numeric field row.
class _ValidatedNumberFieldRow extends StatefulWidget {
  final String label;
  final int value;
  final String? Function(int?) validator;
  final ValueChanged<int> onChanged;
  const _ValidatedNumberFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.validator,
    required this.onChanged,
  });

  @override
  State<_ValidatedNumberFieldRow> createState() =>
      _ValidatedNumberFieldRowState();
}

class _ValidatedNumberFieldRowState
    extends State<_ValidatedNumberFieldRow> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_ValidatedNumberFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_controller.selection.isValid) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(widget.label,
                style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                isDense: true,
                errorText: _error,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                final err = widget.validator(n);
                setState(() => _error = err);
                if (err == null && n != null) widget.onChanged(n);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple unvalidated text field row (for optional fields like GPTXT).
class _TextFieldRow extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _TextFieldRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  State<_TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<_TextFieldRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_controller.selection.isValid) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(widget.label)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
