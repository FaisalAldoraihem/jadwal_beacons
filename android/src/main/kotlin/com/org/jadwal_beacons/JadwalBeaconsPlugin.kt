package com.org.jadwal_beacons

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class JadwalBeaconsPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        initializePlugin(binding.binaryMessenger, binding.applicationContext, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        deinitializePlugin()
    }

    companion object {
        lateinit var jadwalController: JadwalController

        @JvmStatic
        private fun initializePlugin(
            messenger: BinaryMessenger,
            context: Context,
            plugin: JadwalBeaconsPlugin
        ) {

            jadwalController = JadwalController()
            jadwalController.initialize(messenger, context)
        }

        @JvmStatic
        private fun deinitializePlugin() {
            jadwalController.deinitialize()
        }
    }
}