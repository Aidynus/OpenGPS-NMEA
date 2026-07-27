import 'dart:io';

/// Returns `null` when [value] is a valid IPv4/IPv6 address, otherwise an
/// error message suitable for display in a [TextFormField].
String? validateIpAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'IP address cannot be empty';
  }
  try {
    InternetAddress(value.trim());
    return null;
  } on ArgumentError {
    return '"$value" is not a valid IP address';
  }
}

/// Returns `null` when [value] is a valid port number (1–65535), otherwise
/// an error message suitable for display in a [TextFormField].
String? validatePort(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Port cannot be empty';
  }
  final n = int.tryParse(value.trim());
  if (n == null || n < 1 || n > 65535) {
    return 'Port must be a number between 1 and 65535';
  }
  return null;
}

/// Returns `null` when [value] is a valid multicast address (224.0.0.0 –
/// 239.255.255.255), otherwise an error message.
String? validateMulticastAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Multicast address cannot be empty';
  }
  try {
    final addr = InternetAddress(value.trim());
    if (!addr.isMulticast) {
      return '"$value" is not a multicast address (224.x.x.x – 239.x.x.x)';
    }
    return null;
  } on ArgumentError {
    return '"$value" is not a valid IP address';
  }
}

/// Returns `null` when [value] is a valid WebSocket URL (starts with ws://
/// or wss://), otherwise an error message.
String? validateWebSocketUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null; // optional field
  final v = value.trim();
  if (!v.startsWith('ws://') && !v.startsWith('wss://')) {
    return 'URL must start with ws:// or wss://';
  }
  try {
    Uri.parse(v);
    return null;
  } catch (_) {
    return '"$v" is not a valid URL';
  }
}

/// Returns `null` when [value] is a non-empty TAIP device ID.
String? validateTaipDeviceId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Device ID cannot be empty';
  }
  if (value.trim().length > 8) {
    return 'Device ID must be 8 characters or fewer';
  }
  return null;
}

/// Returns `null` when [value] is a valid static threshold (>= 0).
String? validateStaticThreshold(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Threshold cannot be empty';
  }
  final n = double.tryParse(value.trim());
  if (n == null || n < 0) {
    return 'Threshold must be a positive number';
  }
  return null;
}
