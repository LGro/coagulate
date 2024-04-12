// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

import '../../veilid_init.dart';
import '../../veilid_processor/repository/processor_repository.dart';
import 'licenses/page.dart';

Widget _buildNetworkStatusWidget() {
  if (!eventualInitialized.isCompleted) {
    return const Text('Network initialization not completed...');
  } else if (ProcessorRepository
      .instance.processorConnectionState.isPublicInternetReady) {
    return const Text('Network public internet ready.');
  } else {
    return const Text('Network status unknown.');
  }
}

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
            _buildNetworkStatusWidget(),
            // TODO: Add dark mode switch
            // TODO: Add map provider choice
            // TODO: Add custom bootstrap servers choice
            TextButton(
                onPressed: () =>
                    Navigator.of(context).push(LicensesPage.route()),
                child: const Text('Show Open Source Licenses'))
          ])));
}
