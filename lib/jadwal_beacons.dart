
import 'jadwal_beacons_platform_interface.dart';

class JadwalBeacons {
  Future<String?> getPlatformVersion() {
    return JadwalBeaconsPlatform.instance.getPlatformVersion();
  }
}
