import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/providers/location_provider.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/connection_profile.dart';

class ConnectionProfilesScreen extends ConsumerWidget {
  const ConnectionProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(connectionProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New profile',
            onPressed: () => _showEditDialog(context, ref, null),
          ),
        ],
      ),
      body: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'No saved profiles.\nTap + to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showEditDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Create profile'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: profiles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return _ProfileCard(
                  profile: profile,
                  onEdit: () => _showEditDialog(context, ref, profile),
                  onDelete: () => _confirmDelete(context, ref, profile),
                  onApply: () => _applyProfile(ref, profile),
                );
              },
            ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, ConnectionProfile? existing) {
    showDialog<void>(
      context: context,
      builder: (context) => _ProfileEditDialog(
        existing: existing,
        onSave: (profile) {
          ref.read(connectionProfilesProvider.notifier).saveProfile(profile);
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ConnectionProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete profile?'),
        content: Text('Delete "${profile.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(connectionProfilesProvider.notifier).deleteProfile(profile.id);
    }
  }

  void _applyProfile(WidgetRef ref, ConnectionProfile profile) {
    ref.read(appSettingsProvider.notifier).updateSingle((s) => s.copyWith(
          connectionMethodIndex: profile.connectionMethodIndex,
          targetIpAddress: profile.targetIpAddress,
          targetPort: profile.targetPort,
          multicastGroupAddress: profile.multicastGroupAddress,
          socketPort: profile.socketPort,
          websocketPort: profile.websocketPort,
          websocketUrl: profile.websocketUrl,
          taipDeviceId: profile.taipDeviceId,
        ));
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final ConnectionProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApply;

  const _ProfileCard({
    required this.profile,
    required this.onEdit,
    required this.onDelete,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final methodName = _connectionMethodName(profile.connectionMethodIndex);

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(profile.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$methodName · ${profile.targetIpAddress}:${profile.targetPort}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete',
                onPressed: onDelete),
            FilledButton.tonal(
                onPressed: onApply, child: const Text('Apply')),
          ],
        ),
      ),
    );
  }

  String _connectionMethodName(int index) {
    switch (index) {
      case ConnectionMethodPreset.socket:
        return 'Socket';
      case ConnectionMethodPreset.tcpClient:
        return 'TCP Client';
      case ConnectionMethodPreset.udpClient:
        return 'UDP';
      case ConnectionMethodPreset.udpMulticast:
        return 'Multicast';
      case ConnectionMethodPreset.udpBroadcast:
        return 'Broadcast';
      case ConnectionMethodPreset.taipUdp:
        return 'TAIP UDP';
      case ConnectionMethodPreset.webSocket:
        return 'WebSocket';
      default:
        return 'Unknown';
    }
  }
}

// ── Edit dialog ───────────────────────────────────────────────────────────────

class _ProfileEditDialog extends StatefulWidget {
  final ConnectionProfile? existing;
  final ValueChanged<ConnectionProfile> onSave;

  const _ProfileEditDialog({required this.existing, required this.onSave});

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _ipCtrl;
  late final TextEditingController _portCtrl;
  late int _methodIndex;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _ipCtrl = TextEditingController(
        text: p?.targetIpAddress ?? DefaultSettings.defaultTargetIpAddress);
    _portCtrl = TextEditingController(
        text: (p?.targetPort ?? DefaultSettings.defaultPort).toString());
    _methodIndex =
        p?.connectionMethodIndex ?? ConnectionMethodPreset.socket;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.existing?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final profile = ConnectionProfile(
      id: id,
      name: _nameCtrl.text.trim(),
      connectionMethodIndex: _methodIndex,
      targetIpAddress: _ipCtrl.text.trim(),
      targetPort: int.parse(_portCtrl.text.trim()),
      multicastGroupAddress: widget.existing?.multicastGroupAddress ??
          DefaultSettings.defaultMulticastAddress,
      socketPort: widget.existing?.socketPort ?? DefaultSettings.defaultPort,
      websocketPort:
          widget.existing?.websocketPort ?? DefaultSettings.defaultWebsocketPort,
      websocketUrl: widget.existing?.websocketUrl,
      taipDeviceId:
          widget.existing?.taipDeviceId ?? DefaultSettings.defaultTaipDeviceId,
    );
    widget.onSave(profile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New Profile' : 'Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Profile Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _methodIndex,
                decoration:
                    const InputDecoration(labelText: 'Connection Method'),
                items: const [
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.socket,
                      child: Text('Socket (TCP Server)')),
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.tcpClient,
                      child: Text('TCP Client')),
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.udpClient,
                      child: Text('UDP Unicast')),
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.udpMulticast,
                      child: Text('UDP Multicast')),
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.udpBroadcast,
                      child: Text('UDP Broadcast')),
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.taipUdp,
                      child: Text('TAIP UDP')),
                  DropdownMenuItem(
                      value: ConnectionMethodPreset.webSocket,
                      child: Text('WebSocket')),
                ],
                onChanged: (v) => setState(() => _methodIndex = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ipCtrl,
                decoration:
                    const InputDecoration(labelText: 'Target IP Address'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portCtrl,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 65535) {
                    return 'Enter a valid port (1–65535)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
