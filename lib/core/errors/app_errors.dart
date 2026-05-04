class AppError implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppError(this.message, {this.code, this.cause});

  @override
  String toString() => 'AppError($code): $message';
}

class LocationUnavailableError extends AppError {
  const LocationUnavailableError()
      : super('Location services are unavailable');
}

class LocationPermissionDeniedError extends AppError {
  const LocationPermissionDeniedError()
      : super('Location permission denied');
}

class TransmissionError extends AppError {
  const TransmissionError(super.message, {super.code, super.cause});
}

class NetworkUnavailableError extends AppError {
  const NetworkUnavailableError()
      : super('Network is unavailable');
}

class BluetoothUnavailableError extends AppError {
  const BluetoothUnavailableError()
      : super('Bluetooth is unavailable');
}
