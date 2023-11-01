import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jadwal_beacons_platform_interface.dart';

/// An implementation of [JadwalBeaconsPlatform] that uses method channels.
class MethodChannelJadwalBeacons extends JadwalBeaconsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jadwal_beacons');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
