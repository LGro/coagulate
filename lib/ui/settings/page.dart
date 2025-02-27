// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../batch_invite_management/page.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';
import 'licenses/page.dart';

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
                            padding: EdgeInsets.only(right: 4),
                            child: VeilidStatusWidget(statusWidgets: {}))),
                    // ListTile(
                    //     title: const Text('Automatic address resolution'),
                    //     trailing: Switch(
                    //         value: state.autoAddressResolution,
                    //         onChanged: (v) => ())),
                    // ListTile(
                    //     title: const Text('Dark mode'),
                    //     trailing: Switch(
                    //         value: state.darkMode, onChanged: (v) => ())),
                    // ListTile(
                    //     title: const Text('Map provider'),
                    //     trailing: DropdownMenu<String>(
                    //         initialSelection: state.mapProvider,
                    //         requestFocusOnTap: true,
                    //         enabled: false,
                    //         onSelected: (v) => (),
                    //         dropdownMenuEntries: [
                    //           const DropdownMenuEntry(
                    //               value: 'mapbox', label: 'MapBox'),
                    //           const DropdownMenuEntry(
                    //               value: 'osm', label: 'OpenStreetMap'),
                    //           if (Platform.isIOS)
                    //             const DropdownMenuEntry(
                    //                 value: 'apple', label: 'Apple Maps'),
                    //         ])),
                    // TODO: Add option to delete circles
                    // TODO: Move async things to cubit
                    // if (Platform.isIOS) _backgroundPermissionStatus(),
                    // TODO: Add custom bootstrap servers choice -- only allow during initial setup
                    ListTile(
                        onTap: () async => Navigator.of(context).push(
                            MaterialPageRoute<BatchInvitesPage>(
                                builder: (_) => const BatchInvitesPage())),
                        title: const Text('Invitation batches'),
                        trailing: const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.arrow_right))),
                    ListTile(
                        title: const Text('Show open source licenses'),
                        trailing: const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.arrow_right)),
                        onTap: () async =>
                            Navigator.of(context).push(LicensesPage.route())),
                  ]))));
}
