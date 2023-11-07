import 'package:flutter/services.dart';
import 'package:jadwal_beacons/monitoring_result.dart';

import 'jadwal_region.dart';

class JadwalBeacons {
  final MethodChannel _jadwalMethodChannel =
      const MethodChannel("jadwal_method_handler");

  final EventChannel _jadwalMonitoringChannel =
      const EventChannel('jadwal_monitoring_chanel');

  /// Event Channel used to communicate to native code to checking
  /// for bluetooth state changed.
  final EventChannel _jadwalRangingChannel =
      const EventChannel('jadwal_ranging_chanel');

  void startRanging() {
    _jadwalMethodChannel.invokeMethod("startRanging");
  }

  void stopRanging() {
    _jadwalMethodChannel.invokeMethod("stopRanging");
  }

  Stream<BeaconResult> monitorForBeacons(List<JadwalRegion> regions) {
    final list = regions.map((e) => e.toMap()).toList();
    return _jadwalMonitoringChannel
        .receiveBroadcastStream(list)
        .map((event) => BeaconResult.fromMap(event as Map<dynamic, dynamic>));
  }

  Stream<BeaconResult> rangeForBeacons(List<JadwalRegion> regions) {
    final list = regions.map((e) => e.toMap()).toList();
    return _jadwalRangingChannel
        .receiveBroadcastStream(list)
        .map((event) => BeaconResult.fromMap(event as Map<dynamic, dynamic>));
  }
}
