import 'package:flutter/services.dart';
import 'package:jadwal_beacons/monitoring_result.dart';

import 'jadwal_beacons_platform_interface.dart';
import 'jadwal_region.dart';

class JadwalBeacons {
  final EventChannel _jadwalMonitoringChannel =
      const EventChannel('jadwal_monitoring_chanel');

  /// Event Channel used to communicate to native code to checking
  /// for bluetooth state changed.
  final EventChannel _jadwalRangingChannel =
      const EventChannel('jadwal_ranging_channel');

  Future<String?> getPlatformVersion() {
    return JadwalBeaconsPlatform.instance.getPlatformVersion();
  }

  Stream<MonitoringResult> monitorForBeacons(List<JadwalRegion> regions) {
    final list = regions.map((e) => e.toMap()).toList();
    return _jadwalMonitoringChannel.receiveBroadcastStream(list).map(
        (event) => MonitoringResult.fromMap(event as Map<dynamic, dynamic>));
  }
}
