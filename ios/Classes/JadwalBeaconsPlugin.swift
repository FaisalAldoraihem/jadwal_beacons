import CoreLocation
import Flutter
import UIKit

public class JadwalBeaconsPlugin: NSObject, FlutterPlugin {
    let locationManager = CLLocationManager()

    var eventSink: FlutterEventSink?
    var monitoredRegions: [CLBeaconRegion] = []

    init(eventSink: FlutterEventSink?) {
        self.eventSink = eventSink
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jadwal_method_handler", binaryMessenger: registrar.messenger())

        let monitoringEventChannel = FlutterEventChannel(name: "jadwal_monitoring_chanel", binaryMessenger: registrar.messenger())
        let monitoringStreamHandler = MonitoringStreamHandler(channel: channel,registrar: registrar)

        monitoringEventChannel.setStreamHandler(monitoringStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            locationManager.delegate = self
            result("iOS " + UIDevice.current.systemVersion)
        case "startMonitoring":
            locationManager.delegate = self
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func startMonitoring() {
        locationManager.delegate = self

        for region in monitoredRegions {
            locationManager.startMonitoring(for: region)
        }
    }

    func stopMonitoring() {
        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

//     func startRanging() {
//         for constraint in rangingRegions {
//             locationManager.startRangingBeacons(satisfying: constraint)
//         }
//     }
//
//     func stopRanging() {
//         for constraint in rangingRegions {
//             locationManager.stopRangingBeacons(satisfying: constraint)
//         }
//     }
}

extension JadwalBeaconsPlugin: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let sink = eventSink else { return }
        let regionResult = ["event": "didEnterRegion", "proximityUUID": region.identifier]
        sink(regionResult)
    }

    public func locationManager(_: CLLocationManager, didExitRegion region: CLRegion) {
        guard let sink = eventSink else { return }
        let regionResult = ["event": "didExitRegion", "proximityUUID": region.identifier]
        sink(regionResult)
    }

    public func locationManager(_: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard let sink = eventSink else { return }
        let regionResult = ["event": "didStartMonitoringFor", "proximityUUID": region.identifier]
        sink(regionResult)
    }

    public func locationManager(_: CLLocationManager, didRange _: [CLBeacon], satisfying _: CLBeaconIdentityConstraint) {
        guard let sink = eventSink else { return }
    }

    public func locationManager(_: CLLocationManager, didFailRangingFor _: CLBeaconIdentityConstraint, error _: Error) {
        guard let sink = eventSink else { return }
    }

    public func locationManager(_: CLLocationManager, didDetermineState regionState: CLRegionState, for region: CLRegion) {
        guard let sink = eventSink else { return }
        let regionResult = ["event": "didDetermineState", "state": JadwalUtils.parseState(state: regionState.rawValue), "proximityUUID": region.identifier]
        sink(regionResult)
    }
}

public class MonitoringStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    private var fChannel:FlutterMethodChannel
    private var fRegistrar: FlutterPluginRegistrar?

    init(channel:FlutterMethodChannel,registrar: FlutterPluginRegistrar) {
        self.fChannel = channel
        self.fRegistrar = registrar
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        let jadwalPlugin = JadwalBeaconsPlugin(eventSink: eventSink)
        fRegistrar?.addMethodCallDelegate(jadwalPlugin, channel: fChannel)

        guard let regions = arguments as? [Any] else {
            return nil
        }

        for regionMap in regions {
            guard let region = regionMap as? [String: Any] else { return nil }

            guard let uuidString = region["proximityUUID"] as? String else { return nil }

            let uuid = UUID(uuidString: uuidString)!
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
            jadwalPlugin.monitoredRegions.append(beaconRegion)
        }

        jadwalPlugin.startMonitoring()

        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    func sendEvent(_ event: Any) {
        eventSink?(event)
    }
}

// public class RangingStreamHandler: NSObject, FlutterStreamHandler {
//     var eventSink: FlutterEventSink?
//     var jadwalBeaconsPlugin: JadwalBeaconsPlugin?
//
//     init(plugin: JadwalBeaconsPlugin) {
//         jadwalBeaconsPlugin = plugin
//     }
//
//     public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
//         self.eventSink = eventSink
//
//         guard let jadwalPlugin = jadwalBeaconsPlugin else { return nil }
//
//         guard let regions = arguments as? [Any] else {
//             return nil
//         }
//
//         for regionMap in regions {
//             guard let region = regionMap as? [String: Any] else { return nil }
//
//             guard let uuidString = region["proximityUUID"] as? String else { return nil }
//
//             let uuid = UUID(uuidString: uuidString)!
//             let constraint = CLBeaconIdentityConstraint(uuid: uuid)
//             jadwalPlugin.rangingRegions.append(constraint)
//         }
//
//         jadwalPlugin.startRanging()
//
//         return nil
//     }
//
//     public func onCancel(withArguments _: Any?) -> FlutterError? {
//         eventSink = nil
//         jadwalBeaconsPlugin?.rangingRegions = []
//         jadwalBeaconsPlugin = nil
//         return nil
//     }
//
//     func sendEvent(_ event: Any) {
//         eventSink?(event)
//     }
// }
