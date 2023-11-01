import 'package:flutter_test/flutter_test.dart';
import 'package:jadwal_beacons/jadwal_beacons.dart';
import 'package:jadwal_beacons/jadwal_beacons_platform_interface.dart';
import 'package:jadwal_beacons/jadwal_beacons_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJadwalBeaconsPlatform
    with MockPlatformInterfaceMixin
    implements JadwalBeaconsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final JadwalBeaconsPlatform initialPlatform = JadwalBeaconsPlatform.instance;

  test('$MethodChannelJadwalBeacons is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJadwalBeacons>());
  });

  test('getPlatformVersion', () async {
    JadwalBeacons jadwalBeaconsPlugin = JadwalBeacons();
    MockJadwalBeaconsPlatform fakePlatform = MockJadwalBeaconsPlatform();
    JadwalBeaconsPlatform.instance = fakePlatform;

    expect(await jadwalBeaconsPlugin.getPlatformVersion(), '42');
  });
}
