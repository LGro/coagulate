// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

import '../../veilid_processor/views/signal_strength_meter.dart';
import 'licenses/page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Network Status:'),
              const SizedBox(width: 10),
              SignalStrengthMeterWidget()
            ]),
            // TODO: Add dark mode switch
            // TODO: Add map provider choice
            // TODO: Add custom bootstrap servers choice
            TextButton(
                onPressed: () =>
                    Navigator.of(context).push(LicensesPage.route()),
                child: const Text('Show Open Source Licenses'))
          ])));
}
