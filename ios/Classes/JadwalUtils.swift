import CoreLocation

struct JadwalUtils {
    static func dictFromCLBeacon(beacon: CLBeacon) -> [String: Any] {
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

        var beaconData: [String: Any] = [:]

        beaconData["proximityUUID"] = beacon.uuid
        beaconData["major"] = beacon.major
        beaconData["minor"] = beacon.minor
        beaconData["rssi"] = beacon.rssi
        beaconData["accuracy"] = String(format: "%.2f", beacon.accuracy)
        beaconData["proximity"] = proximity

        return beaconData
    }

    static func parseState(state: Int) -> String {
        if state == CLRegionState.inside {
            return "INSIDE"
        } else if state == CLRegionState.outside {
            return "OUTSIDE"
        } else {
            return "UNKNOWN"
        }
    }
}
