package com.org.jadwal_beacons

import android.os.Handler
import android.os.Looper
import android.os.RemoteException
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.MonitorNotifier
import org.altbeacon.beacon.Region

class JadwalMonitoringHandler(private val beaconManager: BeaconManager) {
    private val handler = Handler(Looper.getMainLooper())
    private var regionMonitoring: MutableList<Region>? = null
    private var monitoringEventSink: EventChannel.EventSink? = null

    val monitoringStreamHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(o: Any, eventSink: EventSink) {
            startMonitoring(o, eventSink)
        }

        override fun onCancel(o: Any) {
            stopMonitoring()
        }
    }

    private fun startMonitoring(o: Any, eventSink: EventSink) {
        if (o is List<*>) {
            val list = o as List<*>

            regionMonitoring = mutableListOf()

            for (obj in list) {
                if (obj is Map<*, *>) {
                    val map = obj as Map<*, *>
                    val region = JadwalUtils.mapToRegion(map)
                    if (region != null) {
                        regionMonitoring!!.add(region)
                    }

                }
            }
        } else {
            eventSink.error("Beacon", "invalid object for ranging", null)
            return
        }

        monitoringEventSink = eventSink
        startMonitoring()
    }

    private fun startMonitoring() {
        if (regionMonitoring == null || regionMonitoring?.isEmpty() == true) {
            return
        }

        beaconManager.removeAllMonitorNotifiers()
        beaconManager.addMonitorNotifier(monitorNotifier)

        for (region in regionMonitoring!!) {
            beaconManager.startMonitoring(region)
        }
    }

    fun stopMonitoring() {
        if (regionMonitoring != null && regionMonitoring!!.isNotEmpty()) {
            try {
                for (region in regionMonitoring!!) {
                    beaconManager.stopMonitoring(region)
                }
                beaconManager.removeMonitorNotifier(monitorNotifier)
            } catch (ignored: RemoteException) {
            }
        }
        monitoringEventSink = null
    }

    private val monitorNotifier: MonitorNotifier = object : MonitorNotifier {
        override fun didEnterRegion(region: Region) {
            if (monitoringEventSink != null) {
                val map: MutableMap<String, Any> = HashMap()
                map["event"] = "didEnterRegion"
                map["region"] = JadwalUtils.regionToMap(region)
                handler.post {
                    monitoringEventSink?.success(map)
                }
            }
        }

        override fun didExitRegion(region: Region) {
            if (monitoringEventSink != null) {
                val map: MutableMap<String, Any> = HashMap()
                map["event"] = "didExitRegion"
                map["region"] = JadwalUtils.regionToMap(region)
                handler.post {
                    monitoringEventSink?.success(map)
                }
            }
        }

        override fun didDetermineStateForRegion(state: Int, region: Region) {
            if (monitoringEventSink != null) {
                val map: MutableMap<String, Any> = HashMap()
                map["event"] = "didDetermineStateForRegion"
                map["state"] = JadwalUtils.parseState(state)
                map["region"] = JadwalUtils.regionToMap(region)
                handler.post {
                    monitoringEventSink?.success(map)
                }
            }
        }
    }

}