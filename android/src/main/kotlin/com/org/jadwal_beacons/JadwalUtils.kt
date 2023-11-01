package com.org.jadwal_beacons

import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.Identifier
import org.altbeacon.beacon.MonitorNotifier
import org.altbeacon.beacon.Region
import java.util.Locale

class JadwalUtils {
    companion object {
        fun parseState(state: Int): String {
            return if (state == MonitorNotifier.INSIDE) "INSIDE" else if (state == MonitorNotifier.OUTSIDE) "OUTSIDE" else "UNKNOWN"
        }

        fun beaconToMap(beacon: Beacon): Map<String, Any> {
            return mapOf<String, Any>(
                "proximityUUID" to beacon.id1.toString().uppercase(Locale.getDefault()),
                "major" to beacon.id2.toInt(),
                "minor" to beacon.id3.toInt(),
                "rssi" to beacon.rssi,
                "txPower" to beacon.txPower,
                "accuracy" to String.format(Locale.US, "%.2f", beacon.distance),
                "macAddress" to beacon.bluetoothAddress
            )
        }

        fun regionToMap(region: Region): Map<String, Any> {
            val map = mutableMapOf<String, Any>()

            map["identifier"] = region.uniqueId

            if (region.id1 != null) {
                map["proximityUUID"] = region.id1.toString()
            }
            if (region.id2 != null) {
                map["major"] = region.id2.toInt()
            }
            if (region.id3 != null) {
                map["minor"] = region.id3.toInt()
            }

            return map
        }

        fun mapToRegion(map: Map<*, *>): Region? {
            var identifier = ""
            val identifiers: MutableList<Identifier> = mutableListOf()

            val objectIdentifier = map["identifier"]

            if (objectIdentifier is String) {
                identifier = objectIdentifier
            }

            val uuid = map["proximityUUID"]

            if (uuid is String) {
                identifiers.add(Identifier.parse(uuid))
            }

            val major = map["major"]

            if (major is Int) {
                identifiers.add(Identifier.fromInt(major))
            }

            val minor = map["minor"]

            if (minor is Int) {
                identifiers.add(Identifier.fromInt(minor))
            }

            if (uuid == null) {
                return null
            }

            return Region(
                identifier,
                identifiers
            )
        }

        fun mapToBeacon(map: Map<String, Any>): Beacon {
            val builder = Beacon.Builder()

            val uuid = map["proximityUUID"]

            if (uuid is String) {
                builder.setId1(uuid)
            }


            val major = map["major"]

            if (major is Int) {
                builder.setId2(major.toString())
            }

            val minor = map["minor"]

            if (minor is Int) {
                builder.setId3(minor.toString())
            }


            val txPower = map["txPower"]

            if (txPower is Int) {
                builder.setTxPower(txPower)
            } else {
                builder.setTxPower(-59)
            }

            builder.setDataFields(listOf(0L))
            builder.setManufacturer(0x004c)

            return builder.build()
        }
    }
}