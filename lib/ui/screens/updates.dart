// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:veilid/veilid.dart';

import 'package:veilid_support/veilid_support.dart';

import '../../data/providers/dht.dart';

Widget updateTile(String name, String timing, String change) => ListTile(
        title: Column(children: [
      Row(
        children: [
          Expanded(child: Text(name)),
          Text(timing, style: const TextStyle(color: Colors.black54))
        ],
      ),
      Row(
        children: [Text(change)],
      )
    ]));

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
      ),
      body: ListView(children: [
        updateTile('Ronja Dudeli', '(2d)', 'Name: Timo => Ronja'),
        updateTile(
            'Timo Dudeli', '(1m)', 'Home: Heimsheimer St... => Burgstraße...'),
        updateTile(
            'Helli Schmudela', '(2y)', 'Work: +3011311411 => +2144242200'),
        // Just a toy demo for reading a coagulate dht record
        TextButton(
          child: const Text('Fetch'),
          onPressed: () async {
            // final info = await Veilid.instance.debug('peerinfo');
            // print('Peerinfo: $info');
            // final res = await readPasswordEncryptedDHTRecord(
            //     recordKey: 'VLD0:GstDDrJ3twac6AWVrSA_OECNBhtef9p0TUUULyi5EGM',
            //     secret: 'OIk3Zso4hWWKRGuK');
            // print('Found: ${res}');
            // final pool = DHTRecordPool.instance;
            // final record = await pool.openRead(
            //     Typed<FixedEncodedString43>.fromString(
            //         'VLD0:2uB9taQmO6ATimQt1jbGkf4Qffd8_PCiDdioklYzlhI'),
            //     routingContext: (await Veilid.instance.routingContext())
            //         .withSequencing(Sequencing.ensureOrdered));
            // final raw = await record.get();
            // print('Retrieved: ${utf8.decode(raw!)}');
            // final record = await pool.create(
            //     routingContext: (await Veilid.instance.routingContext())
            //         .withSequencing(Sequencing.ensureOrdered));
            // await record.eventualWriteBytes(utf8.encode('TEST'));
            // await record.close();
            // print(record.key.toString());
          },
        )
      ]));
}
