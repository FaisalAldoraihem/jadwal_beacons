import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jadwal_beacons_method_channel.dart';

abstract class JadwalBeaconsPlatform extends PlatformInterface {
  /// Constructs a JadwalBeaconsPlatform.
  JadwalBeaconsPlatform() : super(token: _token);

  static final Object _token = Object();

  static JadwalBeaconsPlatform _instance = MethodChannelJadwalBeacons();

  /// The default instance of [JadwalBeaconsPlatform] to use.
  ///
  /// Defaults to [MethodChannelJadwalBeacons].
  static JadwalBeaconsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JadwalBeaconsPlatform] when
  /// they register themselves.
  static set instance(JadwalBeaconsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
