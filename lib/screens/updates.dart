// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:veilid/veilid.dart';

import '../veilid_support/veilid_support.dart';

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
            // final profile = await readDHTRecord(PeerDHTRecord(
            //     key: 'VLD0:TDE1OdNxM1gHccaIVZz_l4MCHallNl6sN6ATQvJINho',
            //     psk: 'Uy5OEO9buPFE2xIlfdO4P0bnffGAXVcr'));
            // print('Retrieved: $profile');
            // final res = await Veilid.instance.debug('peerinfo');
            // print('Peerinfo: $res');
            final pool = await DHTRecordPool.instance();
            final record = await pool.create(
                routingContext: (await Veilid.instance.routingContext())
                    .withSequencing(Sequencing.ensureOrdered));
            await record.eventualWriteBytes(utf8.encode('TEST'));
            await record.close();
            print(record.key.toString());
          },
        )
      ]));
}
