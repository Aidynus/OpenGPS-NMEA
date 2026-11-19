import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_constants.dart';

class LocationService {
  final GeolocatorPlatform _geolocator;

  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _subscription;
  StreamController<Position>? _controller;

  int _accuracyPreset = GpsAccuracyPreset.best;
  int _distanceFilter = 0;

  LocationService({GeolocatorPlatform? geolocator})
      : _geolocator = geolocator ?? GeolocatorPlatform.instance;

  static LocationAccuracy accuracyFromPreset(int preset) {
    switch (preset) {
      case GpsAccuracyPreset.best:
        return LocationAccuracy.bestForNavigation;
      case GpsAccuracyPreset.good:
        return LocationAccuracy.best;
      case GpsAccuracyPreset.moderate:
        return LocationAccuracy.high;
      case GpsAccuracyPreset.lazy:
        return LocationAccuracy.medium;
      default:
        return LocationAccuracy.bestForNavigation;
    }
  }

  static int distanceFilterFromPreset(int preset) {
    switch (preset) {
      case GpsAccuracyPreset.best:
        return 0;
      case GpsAccuracyPreset.good:
        return 10;
      case GpsAccuracyPreset.moderate:
        return 100;
      case GpsAccuracyPreset.lazy:
        return 3000;
      default:
        return 0;
    }
  }

  Future<bool> checkAndRequestPermission() async {
    try {
      var permission = await _geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('[LocationService] permission check failed: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('[LocationService] service check failed: $e');
      return false;
    }
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await _geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  Stream<Position> getPositionStream({
    int accuracyPreset = GpsAccuracyPreset.best,
    int? distanceFilterOverride,
    bool allowBackgroundLocationUpdates = true,
  }) {
    _accuracyPreset = accuracyPreset;
    _distanceFilter =
        distanceFilterOverride ?? distanceFilterFromPreset(accuracyPreset);

    _disposeStream();

    final LocationSettings locationSettings =
        defaultTargetPlatform == TargetPlatform.iOS
            ? AppleSettings(
                accuracy: accuracyFromPreset(_accuracyPreset),
                distanceFilter: _distanceFilter,
                activityType: ActivityType.automotiveNavigation,
                allowBackgroundLocationUpdates:
                    allowBackgroundLocationUpdates,
                pauseLocationUpdatesAutomatically: false,
                showBackgroundLocationIndicator:
                    allowBackgroundLocationUpdates,
              )
            : LocationSettings(
                accuracy: accuracyFromPreset(_accuracyPreset),
                distanceFilter: _distanceFilter,
              );

    _positionStream = _geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    _controller = StreamController<Position>.broadcast();
    _subscription = _positionStream!.listen(
      _controller!.add,
      onError: _controller!.addError,
      onDone: _controller!.close,
    );

    return _controller!.stream;
  }

  void pause() {
    _subscription?.pause();
  }

  void resume() {
    _subscription?.resume();
  }

  Future<Position> getCurrentPosition({
    int accuracyPreset = GpsAccuracyPreset.best,
  }) async {
    try {
      return await _geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracyFromPreset(accuracyPreset),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _disposeStream();
  }

  void _disposeStream() {
    _subscription?.cancel();
    _subscription = null;
    _positionStream = null;
    _controller?.close();
    _controller = null;
  }
}