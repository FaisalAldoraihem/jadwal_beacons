import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jadwal_beacons/jadwal_beacons.dart';
import 'package:jadwal_beacons/jadwal_region.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  await GetStorage.init();
  await Permission.location.request();
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
  String _platformVersion = 'Unknown';
  final _jadwalBeaconsPlugin = JadwalBeacons();
  String? event = "";
  String? uuid = "";
  String? state = "";

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();

    event = storage.read("event");
    uuid = storage.read("uuid");
    state = storage.read("state");

    Logger().w(event);
    Logger().w(uuid);
    Logger().w(state);

    _jadwalBeaconsPlugin.monitorForBeacons([
      JadwalRegion(
          identifier: "18ee1516-016b-4bec-ad96-bcb96d166e97",
          proximityUUID: "18ee1516-016b-4bec-ad96-bcb96d166e97")
    ]).listen((event) {
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
              Text('Event:\n ${event ?? ""}',textAlign: TextAlign.center,),
              Text('UUID:\n ${uuid ?? ""}',textAlign: TextAlign.center),
              Text('STATE:\n ${state ?? ""}',textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
