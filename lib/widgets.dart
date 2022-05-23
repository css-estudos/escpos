// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'elgin/elgin_m10_printer_service.dart';

class ScanResultTile extends StatelessWidget {
  ScanResultTile({
    Key? key,
    required this.result,
    this.onTap,
  }) : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;
  bool statusSpressora = false;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text('Dispositivo Não identificado');
      //Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.caption?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'.toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        child: const Text('CONNECT'),
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          onPrimary: Colors.white,
        ),
        onPressed: () async {
          ElginM10PrinterService elginService = ElginM10PrinterService();

          try {
            var aux1 = await elginService.abrirConexaoExternaBlueTooth(
              modelo: 'SmartPOS',
              serial: result.device.id.toString(),
              port: 0,
            );

            final List<int> _escPos = await _customEscPos();

            var aux2 = await elginService.imprimirEscPos(
              rawList: _escPos,
            );
          } finally {
            var aux3 = await elginService.fecharConexao();
          }
        },
      ),
      children: <Widget>[
        _buildAdvRow(context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level', '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context, 'Manufacturer Data', getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data', getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({Key? key, required this.service, required this.characteristicTiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Service'),
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                style:
                    Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).textTheme.caption?.color))
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle: Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                Text('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(color: Theme.of(context).textTheme.caption?.color))
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: onReadPressed,
              ),
              IconButton(
                icon: Icon(Icons.file_upload, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onWritePressed,
              ),
              IconButton(
                icon: Icon(characteristic.isNotifying ? Icons.sync_disabled : Icons.sync,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onNotificationPressed,
              )
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;

  const DescriptorTile({Key? key, required this.descriptor, this.onReadPressed, this.onWritePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text('0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).textTheme.caption?.color))
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key? key, required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subtitle2,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subtitle2?.color,
        ),
      ),
    );
  }
}

PosTextSize tamanhoLetra(int tamanho) {
  switch (tamanho) {
    case 1:
      return PosTextSize.size1;
    case 2:
      return PosTextSize.size2;
    case 3:
      return PosTextSize.size3;
    case 4:
      return PosTextSize.size4;
    case 5:
      return PosTextSize.size5;
    case 6:
      return PosTextSize.size6;
    case 7:
      return PosTextSize.size7;
    case 8:
      return PosTextSize.size8;
    default:
      return PosTextSize.size1;
  }
}

Future<List<int>> _customEscPos2() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  List<int> bytes = [];

  for (int i = 1; i <= 8; i++) {
    for (int j = 1; j <= 8; j++) {
      bytes += generator.text(
        'FA:$i-$j',
        styles: PosStyles(
          bold: false,
          reverse: false,
          underline: false,
          turn90: false,
          align: PosAlign.left,
          height: tamanhoLetra(i),
          width: tamanhoLetra(j),
          fontType: PosFontType.fontA,
        ),
        linesAfter: 0,
        containsChinese: false,
        maxCharsPerLine: 30,
      );
    }
  }

  bytes += generator.feed(4);

  for (int i = 1; i <= 8; i++) {
    for (int j = 1; j <= 8; j++) {
      bytes += generator.text(
        'FA:$i-$j',
        styles: PosStyles(
          bold: false,
          reverse: false,
          underline: false,
          turn90: false,
          align: PosAlign.left,
          height: tamanhoLetra(i),
          width: tamanhoLetra(j),
          fontType: PosFontType.fontB,
        ),
        linesAfter: 0,
        containsChinese: false,
        maxCharsPerLine: 30,
      );
    }
  }

  bytes += generator.reset();

  return bytes;
}

Future<List<int>> _customEscPos() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  List<int> bytes = [];

  bytes += generator.text(
    '================================',
    styles: const PosStyles(
      bold: true,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.center,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    'resultado',
    styles: const PosStyles(
      bold: true,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    'Tempo de luta: 03:52',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    'Vencedor: Claudney Sarti Sessa',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    '================================',
    styles: const PosStyles(
      bold: true,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.center,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    'Marco Polo Viana',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    '  - 3 pontos',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    '  - 2 Faltas',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    'Claudney Sarti Sessa',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    '  - 3 pontos',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    '  - 0 Faltas',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.left,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.text(
    '================================',
    styles: const PosStyles(
      bold: true,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.center,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 0,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.feed(4);

  bytes += generator.reset();

  return bytes;
}

Future<List<int>> _customEscPos1() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  List<int> bytes = [];

  bytes += generator.text('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
  bytes += generator.text('Reverse text', styles: const PosStyles(reverse: true));
  bytes += generator.text('Underlined text', styles: const PosStyles(underline: true), linesAfter: 1);
  bytes += generator.text('Align left', styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text('Align center', styles: const PosStyles(align: PosAlign.center));
  bytes += generator.text('Align right', styles: const PosStyles(align: PosAlign.right), linesAfter: 1);
  bytes += generator.qrcode('Barcode by escpos', size: QRSize.Size4, cor: QRCorrection.H);
  bytes += generator.feed(2);

  bytes += generator.text(
    'CLAUDNEY',
    styles: const PosStyles(
      bold: false,
      reverse: false,
      underline: false,
      turn90: false,
      align: PosAlign.center,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      fontType: PosFontType.fontA,
    ),
    linesAfter: 1,
    containsChinese: false,
    maxCharsPerLine: 30,
  );

  bytes += generator.row([
    PosColumn(
      text: 'col3',
      width: 3,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col6',
      width: 6,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col3',
      width: 3,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
  ]);

  bytes += generator.text('Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  bytes += generator.reset();

  return bytes;
}
