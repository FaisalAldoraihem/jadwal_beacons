import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jadwal_beacons/jadwal_beacons_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelJadwalBeacons platform = MethodChannelJadwalBeacons();
  const MethodChannel channel = MethodChannel('jadwal_beacons');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
