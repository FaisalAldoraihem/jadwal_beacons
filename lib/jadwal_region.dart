class JadwalRegion {
  String identifier;
  String proximityUUID;

  JadwalRegion({
    required this.identifier,
    required this.proximityUUID
  });


  // Method to transform the class instance into a map.
  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'proximityUUID': proximityUUID
    };
  }

  @override
  String toString() {
    return 'JadwalRegion{identifier: $identifier, proximityUUID: $proximityUUID}';
  }
}
