import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jadwal_beacons/jadwal_beacons.dart';
import 'package:jadwal_beacons/jadwal_region.dart';
import 'package:logger/logger.dart' as log;
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  await GetStorage.init();
  await Permission.locationAlways.request();

  await Permission.bluetoothScan.request();
  await Permission.bluetooth.request();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _jadwalBeaconsPlugin = JadwalBeacons();
  final flutterReactiveBle = FlutterReactiveBle();

  String? event = "";
  String? uuid = "";
  String? state = "";
  String? major = "";
  String? minor = "";

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    final logger = log.Logger();


    event = storage.read("event");
    uuid = storage.read("uuid");
    state = storage.read("state");
    major = storage.read("major");
    minor = storage.read("minor");

    logger.w(event);
    logger.w(uuid);
    logger.w(state);

    _jadwalBeaconsPlugin.monitorForBeacons([
      JadwalRegion(
          identifier: "18ee1516-016b-4bec-ad96-bcb96d166e97",
          proximityUUID: "18ee1516-016b-4bec-ad96-bcb96d166e97")
    ]).listen((event) {
      logger.w(event);

      _jadwalBeaconsPlugin.startRanging();

      if (event.beacons != null) {
        _jadwalBeaconsPlugin.stopRanging();
        GetStorage().write('major', event.beacons!["major"]);
        GetStorage().write('minor', event.beacons!["minor"]);
      }

      GetStorage().write('event', event.event);

      if (event.state != null) {
        GetStorage().write('state', event.state);
      }

      GetStorage().write('uuid', event.uuid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Event:\n ${event ?? ""}',
                textAlign: TextAlign.center,
              ),
              Text('UUID:\n ${uuid ?? ""}', textAlign: TextAlign.center),
              Text('STATE:\n ${state ?? ""}', textAlign: TextAlign.center),
              Text('Major:\n ${major ?? ""}', textAlign: TextAlign.center),
              Text('Minor:\n ${minor ?? ""}', textAlign: TextAlign.center),

            ],
          ),
        ),
      ),
    );
  }
}
