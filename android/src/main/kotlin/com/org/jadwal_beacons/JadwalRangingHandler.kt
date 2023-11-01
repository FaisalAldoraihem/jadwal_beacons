package com.org.jadwal_beacons

import android.os.Handler
import android.os.Looper
import android.os.RemoteException
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.RangeNotifier
import org.altbeacon.beacon.Region

class JadwalRangingHandler(private val beaconManager: BeaconManager) {
    private val handler = Handler(Looper.getMainLooper())
    private var regionRanging: MutableList<Region>? = null
    private var rangingEventSink: EventSink? = null

    val rangingStreamHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(o: Any, eventSink: EventSink) {
            startRanging(o, eventSink)
        }

        override fun onCancel(o: Any) {
            stopRanging()
        }
    }

    private fun startRanging(o: Any, eventSink: EventSink) {
        if (o is List<*>) {
            val list = o as List<*>

            regionRanging = mutableListOf()

            for (obj in list) {
                if (obj is Map<*, *>) {
                    val map = obj as Map<*, *>
                    val region = JadwalUtils.mapToRegion(map)
                    if (region != null) {
                        regionRanging!!.add(region)
                    }

                }
            }
        } else {
            eventSink.error("Beacon", "invalid object for ranging", null)
            return
        }

        rangingEventSink = eventSink
        startRanging()
    }

    private fun startRanging() {
        if (regionRanging == null || regionRanging?.isEmpty() == true) {
            return
        }

        beaconManager.removeAllRangeNotifiers()
        beaconManager.addRangeNotifier(rangeNotifier)
        for (region in regionRanging!!) {
            beaconManager.startRangingBeacons(region)
        }

    }

    fun stopRanging() {
        if (regionRanging != null && !regionRanging!!.isEmpty()) {
            try {
                for (region in regionRanging!!) {
                    beaconManager.stopRangingBeacons(region)
                }
                beaconManager.removeRangeNotifier(rangeNotifier)
            } catch (ignored: RemoteException) {
            }
        }
        rangingEventSink = null
    }

    private val rangeNotifier =
        RangeNotifier { collection, region ->
            if (rangingEventSink != null) {
                val map: MutableMap<String, Any> = emptyMap<String, Any>().toMutableMap()

                for (beacon in collection) {
                    map[beacon.id1.toString()] = JadwalUtils.beaconToMap(beacon)
                }

                map["region"] = JadwalUtils.regionToMap(region)

                handler.post {
                    rangingEventSink?.success(map)
                }
            }
        }

}