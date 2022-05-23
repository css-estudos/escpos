import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:awesome_dropdown/awesome_dropdown.dart';
import 'package:escpos/device_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'widgets.dart';

class FindDevicesScreen extends StatelessWidget {
  final jobRoleCtrl = TextEditingController();

  FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          ElevatedButton(
            child: const Text('TURN OFF'),
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            onPressed: Platform.isAndroid ? () => FlutterBluePlus.instance.turnOff() : null,
          ),
        ],
      ),
      backgroundColor: Colors.green,
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                child: Center(
                  child: Column(
                    children: [
                      AwesomeDropDown(
                        elevation: 0,
                        isPanDown: false,
                        dropDownBottomBorderRadius: 0,
                        dropDownTopBorderRadius: 0,
                        dropDownBorderRadius: 0,
                        padding: 15,
                        dropDownList: const [
                          'Abc',
                          'DEF',
                          'GHI',
                          'JKL',
                          'MNO',
                          'PQR',
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: CustomDropdown(
                          hintText: 'Select job role',
                          items: [
                            'Developer',
                            'Designer',
                            'Consultant',
                            'Student',
                          ],
                          controller: jobRoleCtrl,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  StreamBuilder<List<BluetoothDevice>>(
                    stream: Stream.periodic(const Duration(seconds: 2))
                        .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map((d) => ListTile(
                                title: Text(d.name),
                                subtitle: Text(d.id.toString()),
                                trailing: StreamBuilder<BluetoothDeviceState>(
                                  stream: d.state,
                                  initialData: BluetoothDeviceState.disconnected,
                                  builder: (c, snapshot) {
                                    if (snapshot.data == BluetoothDeviceState.connected) {
                                      return ElevatedButton(
                                        child: const Text('OPEN'),
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(builder: (context) => DeviceScreen(device: d))),
                                      );
                                    }
                                    return Text(snapshot.data.toString());
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  StreamBuilder<List<ScanResult>>(
                    stream: FlutterBluePlus.instance.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) {
                      return Column(
                        children: snapshot.data!
                            .map(
                              (r) => ScanResultTile(
                                result: r,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      r.device.connect();
                                      return DeviceScreen(device: r.device);
                                    },
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () => FlutterBluePlus.instance.startScan(
                timeout: const Duration(
                  seconds: 4,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
