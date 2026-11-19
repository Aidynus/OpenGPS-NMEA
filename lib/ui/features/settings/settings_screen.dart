import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/password_hasher.dart';
import '../../../data/providers/location_provider.dart';
import '../../../domain/models/app_settings.dart';
import '../../../l10n/tr.dart';
import '../../core/navigation.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    ref.watch(languageProvider); // rebuild tooltips on language change

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const DecoratedBox(decoration: AppGradients.appBar),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: Tr.s('Back'),
          onPressed: () => goBackOrHome(context),
        ),
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: Tr.s('Reset to defaults'),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GeneralSection(settings: settings, notifier: notifier),
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
          const _LanguageRow(),
          _DropdownRow<int>(
            label: 'GPS Accuracy',
            value: settings.accuracyIndex,
            items: const [
              DropdownMenuItem(
                  value: GpsAccuracyPreset.best, child: Text('Very Best')),
              DropdownMenuItem(
                  value: GpsAccuracyPreset.good, child: Text('Pretty Good')),
              DropdownMenuItem(
                  value: GpsAccuracyPreset.moderate, child: Text('Moderate')),
              DropdownMenuItem(
                  value: GpsAccuracyPreset.lazy, child: Text('Lazy')),
            ],
            onChanged: (v) => notifier.updateSingle(
                (s) => s.copyWith(accuracyIndex: v ?? s.accuracyIndex)),
          ),
          _DropdownRow<int>(
            label: 'Update Frequency',
            value: settings.frequencyIndex,
            items: const [
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.noDelay,
                  child: Text('No Delay')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.oneSecond,
                  child: Text('1 second')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.fiveSeconds,
                  child: Text('5 seconds')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.thirtySeconds,
                  child: Text('30 seconds')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.sixtySeconds,
                  child: Text('1 minute')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.fiveMinutes,
                  child: Text('5 minutes')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.thirtyMinutes,
                  child: Text('30 minutes')),
              DropdownMenuItem(
                  value: TransmissionFrequencyPreset.oneHour,
                  child: Text('1 hour')),
            ],
            onChanged: (v) => notifier.updateSingle(
                (s) => s.copyWith(frequencyIndex: v ?? s.frequencyIndex)),
          ),
          _DropdownRow<int>(
            label: 'Speed Unit',
            value: settings.speedUnitIndex,
            items: const [
              DropdownMenuItem(
                  value: SpeedUnitPreset.knots, child: Text('Knots')),
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
            onChanged: (v) => notifier
                .updateSingle((s) => s.copyWith(operateInBackground: v)),
          ),
          _SwitchRow(
            label: 'Display Decimal Minutes',
            value: settings.displayDecimalMinutes,
            onChanged: (v) => notifier
                .updateSingle((s) => s.copyWith(displayDecimalMinutes: v)),
          ),
          _SwitchRow(
            label: 'Disable When Static',
            value: settings.disableWhenStatic,
            onChanged: (v) =>
                notifier.updateSingle((s) => s.copyWith(disableWhenStatic: v)),
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

// ── Language selector ─────────────────────────────────────────────────────────

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(languageProvider);
    return _DropdownRow<String>(
      label: 'Language',
      value: mode,
      items: const [
        DropdownMenuItem(value: 'system', child: Text('System default')),
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'ru', child: Text('Русский')),
      ],
      onChanged: (v) {
        if (v == null) return;
        ref.read(languageProvider.notifier).state = v;
        Tr.setMode(v);
      },
    );
  }
}

// ── Static threshold slider ───────────────────────────────────────────────────

class _StaticThresholdSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _StaticThresholdSlider(
      {super.key, required this.value, required this.onChanged});

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
              const Text('Static Threshold', style: TextStyle(fontSize: 14)),
              Text('${value.toStringAsFixed(1)} ${Tr.s('m')}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Slider(
            value: value.clamp(0.5, 50.0),
            min: 0.5,
            max: 50.0,
            divisions: 99,
            label: '${value.toStringAsFixed(1)} ${Tr.s('m')}',
            onChanged: (v) => onChanged(double.parse(v.toStringAsFixed(1))),
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
      widget.notifier.updateSingle((s) => s.copyWith(passwordHash: null));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lock removed')),
      );
    } else {
      final hash = hashPassword(raw);
      widget.notifier.updateSingle((s) => s.copyWith(passwordHash: hash));
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
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(isLocked ? 'Settings locked' : 'Settings unlocked',
                  style: const TextStyle(fontSize: 14)),
              const Spacer(),
              if (isLocked)
                TextButton(
                  onPressed: () => widget.notifier
                      .updateSingle((s) => s.copyWith(passwordHash: null)),
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
                    labelText: Tr.s(isLocked ? 'Change password' : 'Set password'),
                    hintText:
                        Tr.s(isLocked ? 'Enter new password' : 'Enter password'),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
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
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});

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
  const _DropdownRow(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

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
