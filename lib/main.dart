import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global crash handlers ────────────────────────────────────────────────

  // Catch Flutter framework errors (widget build, layout, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      // In production: send to crash reporting service.
      // FlutterError.presentError hides the red screen in release builds.
      FlutterError.presentError(details);
      debugPrint('[CRASH] Flutter error: ${details.exceptionAsString()}');
    } else {
      // In debug: default behavior shows the red error screen.
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Catch Dart errors that are not caught by Flutter's framework
  // (e.g., errors thrown in isolates, platform channel callbacks).
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[CRASH] Platform error: $error\n$stack');
    // Return true to mark the error as handled and suppress the crash.
    return true;
  };

  runApp(
    const ProviderScope(
      child: OpenGpsNmeaApp(),
    ),
  );
}
