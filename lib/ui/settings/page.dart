// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

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
          create: (context) => SettingsCubit(),
          child: BlocConsumer<SettingsCubit, SettingsState>(
              listener: (context, state) => {},
              builder: (context, state) => ListView(children: [
                    const ListTile(
                        title: Text('Network status'),
                        trailing: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: SignalStrengthMeterWidget())),
                    ListTile(
                        title: const Text('Automatic address resolution'),
                        trailing: Switch(
                            value: state.autoAddressResolution,
                            onChanged: (v) => ())),
                    // ListTile(
                    //     title: const Text('Dark mode'),
                    //     trailing: Switch(
                    //         value: state.darkMode, onChanged: (v) => ())),
                    ListTile(
                        title: const Text('Map provider'),
                        trailing: DropdownMenu<String>(
                            initialSelection: state.mapProvider,
                            requestFocusOnTap: true,
                            enabled: false,
                            onSelected: (v) => (),
                            dropdownMenuEntries: [
                              const DropdownMenuEntry(
                                  value: 'mapbox', label: 'MapBox'),
                              const DropdownMenuEntry(
                                  value: 'osm', label: 'OpenStreetMap'),
                              if (Platform.isIOS)
                                const DropdownMenuEntry(
                                    value: 'apple', label: 'Apple Maps'),
                            ])),
                    // TODO: Add option to delete circles
                    // TODO: Move async things to cubit
                    // if (Platform.isIOS) _backgroundPermissionStatus(),
                    // TODO: Add custom bootstrap servers choice
                    ListTile(
                        title: const Text('Show open source licenses'),
                        trailing: const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.arrow_right)),
                        onTap: () async =>
                            Navigator.of(context).push(LicensesPage.route())),
                  ]))));
}
