package com.org.jadwal_beacons

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.BeaconParser

class JadwalController : MethodCallHandler {
    private val iBeaconLayout = BeaconParser()
        .setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24")

    private lateinit var jadwalMonitoringHandler: JadwalMonitoringHandler
    private lateinit var jadwalRangingHandler: JadwalRangingHandler

    private lateinit var beaconManager: BeaconManager
    private lateinit var jadwalMethodChannel: MethodChannel
    private lateinit var rangingEventChannel: EventChannel
    private lateinit var monitoringEventChannel: EventChannel


    internal fun initialize(messenger: BinaryMessenger, context: Context) {
        beaconManager = BeaconManager.getInstanceForApplication(context.applicationContext)

        if (!beaconManager.beaconParsers.contains(iBeaconLayout)) {
            beaconManager.beaconParsers.clear()
            beaconManager.beaconParsers.add(iBeaconLayout)
        }

        jadwalMethodChannel = MethodChannel(messenger, "jadwal_method_handler")
        jadwalMethodChannel.setMethodCallHandler(this)

        jadwalMonitoringHandler = JadwalMonitoringHandler(beaconManager)
        jadwalRangingHandler = JadwalRangingHandler(beaconManager)

        rangingEventChannel = EventChannel(messenger, "jadwal_ranging_channel")
        rangingEventChannel.setStreamHandler(jadwalRangingHandler.rangingStreamHandler)

        monitoringEventChannel = EventChannel(messenger, "jadwal_monitoring_chanel")
        monitoringEventChannel.setStreamHandler(jadwalMonitoringHandler.monitoringStreamHandler)
    }

    internal fun deinitialize() {
        jadwalMethodChannel.setMethodCallHandler(null)
        rangingEventChannel.setStreamHandler(null)
        monitoringEventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        TODO("Not yet implemented")
    }

    private fun startRanging() {

    }


}