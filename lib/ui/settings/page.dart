// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

import '../../veilid_processor/views/signal_strength_meter.dart';
import 'cubit.dart';
import 'licenses/page.dart';

// TODO: Move to cubit?
Future<Widget> _backgroundPermissionStatus() async {
  final hasPermission = await Workmanager().checkBackgroundRefreshPermission();
  if (hasPermission != BackgroundRefreshPermissionState.available) {
    return Text('Background app refresh is disabled, please enable in '
        'App settings. Status ${hasPermission.name}');
  }
  return const Text('Background app refresh is enabled :)');
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocProvider(
          create: (context) => SettingsCubit(
              const SettingsState(status: SettingsStatus.initial, message: '')),
          child: BlocConsumer<SettingsCubit, SettingsState>(
              listener: (context, state) => {},
              builder: (context, state) => Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Text('Network Status:'),
                          SizedBox(width: 10),
                          SignalStrengthMeterWidget()
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text('Automatic address resolution')),
                          Switch(
                              value: true,
                              activeColor: Colors.green,
                              // TODO: Add state handling
                              onChanged: (bool value) {})
                        ]),
                        // TODO: Move async things to cubit
                        // if (Platform.isIOS) _backgroundPermissionStatus(),
                        // TODO: Add dark mode switch
                        // TODO: Add map provider choice
                        // TODO: Add custom bootstrap servers choice
                        TextButton(
                            onPressed: () async => Navigator.of(context)
                                .push(LicensesPage.route()),
                            child: const Text('Show Open Source Licenses'))
                      ])))));
}
