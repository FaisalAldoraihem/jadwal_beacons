import Flutter
import UIKit

public class JadwalBeaconsPlugin: NSObject, FlutterPlugin {
    let locationManager = CLLocationManager()

    var monitoringStreamHandler: MonitoringStreamHandler?
    var rangingStreamHandler: RangingStreamHandler?
    var eventsStreamHandler: EventsStreamHandler?

    var monitoredRegions: [CLBeaconRegion] = []
    var rangingRegions: [CLBeaconIdentityConstraint] = []

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jadwal_method_handler", binaryMessenger: registrar.messenger())

        let instance = JadwalBeaconsPlugin()

        let rangingEventChannel = FlutterEventChannel(name: "jadwal_ranging_channel", binaryMessenger: registrar.messenger())
        let monitoringEventChannel = FlutterEventChannel(name: "jadwal_monitoring_chanel", binaryMessenger: registrar.messenger())

        monitoringStreamHandler = MonitoringStreamHandler()
        rangingStreamHandler = RangingStreamHandler()

        monitoringEventChannel?.jadwalBeaconsPlugin = instance
        rangingStreamHandler?.jadwalBeaconsPlugin = instance

        monitoringEventChannel.setStreamHandler(monitoringStreamHandler)
        rangingEventChannel.setStreamHandler(rangingStreamHandler)

        locationManager.delegate = self

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func startMonitoring() {
        for region in monitoredRegions {
            locationManager.startMonitoring(for: region)
        }
    }

    func stopMonitoring() {
        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

    func startRanging() {
        for constraint in rangingRegions {
            locationManager.startRangingBeacons(satisfying: constraint)
        }
    }

    func stopRanging() {
        for constraint in rangingRegions {
            locationManager.stopRangingBeacons(satisfying: constraint)
        }
    }
}

extension JadwalBeaconsPlugin: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let sink = monitoringStreamHandler else { return }
        let regionResult = ["event": "didEnterRegion", "proximityUUID": region.identifier]
        sink.sendEvent(regionResult)
    }

    func locationManager(_: CLLocationManager, didExitRegion region: CLRegion) {
        guard let sink = monitoringStreamHandler else { return }
        let regionResult = ["event": "didExitRegion", "proximityUUID": region.identifier]
        sink.sendEvent(regionResult)
    }

    func locationManager(_: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard let sink = rangingStreamHandler else { return }
        let regionResult = ["event": "didStartMonitoringFor", "proximityUUID": region.identifier]
        sink.sendEvent(regionResult)
    }

    func locationManager(_: CLLocationManager, didRange beacons: [CLBeacon], satisfying _: CLBeaconIdentityConstraint) {
        guard let sink = rangingStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didFailRangingFor _: CLBeaconIdentityConstraint, error _: Error) {
        guard let sink = rangingStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didDetermineState regionState: CLRegionState, for region: CLRegion) {
        guard let sink = eventsStreamHandler else { return }
        let regionResult = ["event": "didDetermineState","state": JadwalUtils.parseState(regionState.rawValue),"proximityUUID": region.identifier]
        sink.sendEvent(regionResult)
    }
}

public class MonitoringStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var jadwalBeaconsPlugin: JadwalBeaconsPlugin?

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        guard let jadwalPlugin = jadwalBeaconsPlugin else { return nil }

        guard let regions = arguments as? [Any] else {
            return nil
        }

        for regionMap in regions {
            guard let region = regionMap as [String: Any] else { return nil }

            guard let uuidString = region["proximityUUID"] as String else { return nil }

            let uuid = UUID(uuidString: uuidString)
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
            jadwalPlugin.monitoredRegions.append(beaconRegion)
        }

        jadwalPlugin.startMonitoring()

        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        jadwalBeaconsPlugin?.monitoredRegions = []
        jadwalBeaconsPlugin = nil
        return nil
    }

    func sendEvent(_ event: Any) {
        eventSink?(event)
    }
}

public class RangingStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var jadwalBeaconsPlugin: JadwalBeaconsPlugin?

    public func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        guard let jadwalPlugin = jadwalBeaconsPlugin else { return nil }

        guard let regions = arguments as? [Any] else {
            return nil
        }

        for regionMap in regions {
            guard let region = regionMap as [String: Any] else { return nil }

            guard let uuidString = region["proximityUUID"] as String else { return nil }

            let uuid = UUID(uuidString: uuidString)
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            jadwalPlugin.rangingRegions.append(constraint)
        }

        jadwalPlugin.startRanging()

        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        jadwalBeaconsPlugin?.rangingRegions = []
        jadwalBeaconsPlugin = nil
        return nil
    }

    func sendEvent(_ event: Any) {
        eventSink?(event)
    }
}