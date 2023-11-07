class BeaconResult {
  String? uuid;
  String? event;
  String? state;
  Map<dynamic,dynamic>? beacons;

  BeaconResult({
    required this.uuid,
    required this.event,
    required this.state,
    required this.beacons
  });

  // Static method to create an instance of MonitoringResult from a map.
  static BeaconResult fromMap(Map<dynamic, dynamic> map) {
    return BeaconResult(
      uuid: map['proximityUUID'],
      event: map['event'],
      state: map['state'],
      beacons:  map['beacons']
    );
  }

  // Method to transform the class instance into a map.
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'event': event,
      'state': state,
      'beacons': beacons
    };
  }

  @override
  String toString() {
    return 'BeaconResult{uuid: $uuid, event: $event, state: $state, beacons: ${beacons.toString()}';
  }
}
