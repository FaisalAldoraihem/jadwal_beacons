import CoreLocation

struct JadwalUtils {
    static func dictFromCLBeacon(beacon:CLBeacon) -> [String: Any]{
        var proximity = ""

        switch beacon.proximity {
            case .unknown:
                proximity = "unknown"
            case .immediate:
                proximity = "immediate"
            case .near:
                proximity = "near"
            case .far:
                proximity = "far"
        }
        
        var beaconData:Dictionary<String, Any> = [:]

        beaconData["proximityUUID"] = beacon.uuid
        beaconData["major"] = beacon.major
        beaconData["minor"] = beacon.minor
        beaconData["rssi"] = beacon.rssi
        beaconData["accuracy"] = String(format:"%.2f", beacon.accuracy)
        beaconData["proximity"] = proximity

        return beaconData
    }
}