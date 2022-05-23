import 'dart:io';
import 'dart:math';

import 'package:escpos/bluetooth_off_screen.dart';
import 'package:escpos/find_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'widgets.dart';

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
