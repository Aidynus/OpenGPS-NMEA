class AppError implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppError(this.message, {this.code, this.cause});

  @override
  String toString() => 'AppError($code): $message${cause != null ? ' — caused by: $cause' : ''}';
}

class LocationUnavailableError extends AppError {
  const LocationUnavailableError({Object? cause})
      : super('Location services are unavailable', code: 'LOC_UNAVAILABLE', cause: cause);
}

class LocationPermissionDeniedError extends AppError {
  /// Whether the permission was permanently denied (denied forever).
  final bool isPermanent;

  const LocationPermissionDeniedError({this.isPermanent = false, Object? cause})
      : super(
          isPermanent
              ? 'Location permission permanently denied. Please enable it in app Settings.'
              : 'Location permission denied',
          code: 'LOC_PERMISSION_DENIED',
          cause: cause,
        );
}

class TransmissionError extends AppError {
  const TransmissionError(super.message, {super.code, super.cause});
}

class PortInUseError extends AppError {
  final int port;

  PortInUseError(this.port, {Object? cause})
      : super(
          'Port $port is already in use. Change the port in Settings → Network.',
          code: 'PORT_IN_USE',
          cause: cause,
        );
}

class NetworkUnavailableError extends AppError {
  const NetworkUnavailableError({Object? cause})
      : super('Network is unavailable', code: 'NET_UNAVAILABLE', cause: cause);
}

class BluetoothUnavailableError extends AppError {
  const BluetoothUnavailableError({Object? cause})
      : super('Bluetooth is unavailable', code: 'BT_UNAVAILABLE', cause: cause);
}

class InvalidAddressError extends AppError {
  final String address;

  InvalidAddressError(this.address, {Object? cause})
      : super(
          '"$address" is not a valid IP address.',
          code: 'INVALID_ADDRESS',
          cause: cause,
        );
}

class InvalidPortError extends AppError {
  final int port;

  InvalidPortError(this.port, {Object? cause})
      : super(
          '$port is not a valid port number (1–65535).',
          code: 'INVALID_PORT',
          cause: cause,
        );
}
