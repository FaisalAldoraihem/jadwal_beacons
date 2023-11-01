import Flutter
import UIKit

public class JadwalBeaconsPlugin: NSObject, FlutterPlugin {
    let locationManager = CLLocationManager()

    var monitoringStreamHandler: MonitoringStreamHandler?
    var rangingStreamHandler: RangingStreamHandler?
    var eventsStreamHandler: EventsStreamHandler?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jadwal_method_handler", binaryMessenger: registrar.messenger())

        let instance = JadwalBeaconsPlugin()

        let rangingEventChannel = FlutterEventChannel(name: "jadwal_ranging_channel", binaryMessenger: registrar.messenger())
        let monitoringEventChannel = FlutterEventChannel(name: "jadwal_monitoring_chanel", binaryMessenger: registrar.messenger())
        let eventsEventChannel = FlutterEventChannel(name: "jadwal_events_chanel", binaryMessenger: registrar.messenger())

        monitoringStreamHandler = MonitoringStreamHandler()
        rangingStreamHandler = RangingStreamHandler()
        eventsStreamHandler = EventsStreamHandler()

        monitoringEventChannel?.jadwalBeaconsPlugin = instance
        rangingStreamHandler?.jadwalBeaconsPlugin = instance

        monitoringEventChannel.setStreamHandler(monitoringStreamHandler)
        rangingEventChannel.setStreamHandler(rangingStreamHandler)
        eventsEventChannel.setStreamHandler(eventsStreamHandler)

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

    func startMonitoring() {}

    func stopMonitoring() {}

    func startRanging() {}

    func stopRanging() {}
}

extension JadwalBeaconsPlugin: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didEnterRegion _: CLRegion) {
        guard let sink = monitoringStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didExitRegion _: CLRegion) {
        guard let sink = monitoringStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didStartMonitoringFor _: CLRegion) {
        guard let sink = rangingStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didRange _: [CLBeacon], satisfying _: CLBeaconIdentityConstraint) {
        guard let sink = rangingStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didFailRangingFor _: CLBeaconIdentityConstraint, error _: Error) {
        guard let sink = rangingStreamHandler else { return }
    }

    func locationManager(_: CLLocationManager, didDetermineState _: CLRegionState, for _: CLRegion) {
        guard let sink = eventsStreamHandler else { return }
    }
}

public class MonitoringStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var jadwalBeaconsPlugin: JadwalBeaconsPlugin?

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        var recivedRegions:[CLBeaconRegion] = []

        guard let regions = arguments as? [Any] else {
            return nil
        }

        for reagionMap in regions {
            guard let region = reagionMap as [String:Any] else {return nil}
            
            guard let uuidString = region["proximityUUID"] as String else {return nil}

            let uuid = UUID(uuidString: uuidString)
            let constraint = CLBeaconIdentityConstraint(uuid: uuid)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
            recivedRegions.append(beaconRegion)
        }

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

public class RangingStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var jadwalBeaconsPlugin: JadwalBeaconsPlugin?

    public func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
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

public class EventsStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?

    public func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
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
