class MonitoringResult {
  String uuid;
  String event;
  String? state;

  MonitoringResult({
    required this.uuid,
    required this.event,
    required this.state,
  });

  // Static method to create an instance of MonitoringResult from a map.
  static MonitoringResult fromMap(Map<dynamic, dynamic> map) {
    return MonitoringResult(
      uuid: map['proximityUUID'] ?? '',
      event: map['event'] ?? '',
      state: map['state'],
    );
  }

  // Method to transform the class instance into a map.
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'event': event,
      'state': state,
    };
  }

  @override
  String toString() {
    return 'MonitoringResult{uuid: $uuid, event: $event, state: $state}';
  }
}
