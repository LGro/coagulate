// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import '../../data/repositories/settings.dart';
import '../../notification_service.dart';
import '../batch_invite_management/page.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';
import 'licenses/page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocProvider(
          create: (_) => SettingsCubit(context.read<ContactsRepository>(),
              context.read<SettingsRepository>()),
          child: BlocConsumer<SettingsCubit, SettingsState>(
              listener: (context, state) => {},
              builder: (blocContext, state) => ListView(children: [
                    const ListTile(
                        title: Text('Network status'),
                        trailing: Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: VeilidStatusWidget(statusWidgets: {}))),
                    ListTile(
                        title: const Text('Map provider'),
                        trailing: DropdownMenu<MapProvider>(
                            initialSelection: state.mapProvider,
                            onSelected: (v) => (v == null)
                                ? null
                                : blocContext
                                    .read<SettingsCubit>()
                                    .setMapProvider(v),
                            dropdownMenuEntries: MapProvider.values
                                // TODO: Remove when support for custom urls lands
                                .sublist(0, 2)
                                .map((v) => DropdownMenuEntry(
                                    value: v,
                                    label: v.toString().split('.').last))
                                .toList())),
                    // TODO: Make sure that when re-enabling this the marker labels have the correct color when selecting the opposite of the system theme
                    // if (state.mapProvider == MapProvider.maptiler)
                    //   ListTile(
                    //       title: const Text('Map dark mode'),
                    //       trailing: Switch(
                    //           value: state.darkMode,
                    //           onChanged: blocContext
                    //               .read<SettingsCubit>()
                    //               .setDarkMode)),
                    // TODO: Add option
                    // if (state.mapProvider == MapProvider.custom)
                    //   const ListTile(title: Text('Set custom map server url')),
                    // TODO: Move async things to cubit
                    // if (Platform.isIOS) _backgroundPermissionStatus(),
                    if (kDebugMode)
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
                    if (kDebugMode)
                      ListTile(
                          title: const Text('Add dummy contact'),
                          onTap: blocContext
                              .read<SettingsCubit>()
                              .addDummyContact),
                    if (kDebugMode)
                      ListTile(
                          title: const Text('Notify'),
                          onTap: () async =>
                              NotificationService().showNotification(
                                0,
                                'Simple Notification',
                                'This is a simple notification example.',
                              )),
                  ]))));
}
