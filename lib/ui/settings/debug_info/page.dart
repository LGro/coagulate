// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/contacts.dart';
import '../../../debug_log.dart';

class DebugInfoPage extends StatelessWidget {
  const DebugInfoPage({super.key});

  static Route<void> route() => MaterialPageRoute(
      fullscreenDialog: true, builder: (context) => const DebugInfoPage());

  @override
  Widget build(BuildContext context) {
    final combinedInfo = [
      'Database',
      context.read<ContactsRepository>().persistentStorage.debugInfo(),
      '---',
      'Repository',
      'Contacts: ${context.read<ContactsRepository>().getContacts().length}',
      '---',
      'Log',
      ...DebugLogger().getRecentLogs(count: 100),
    ].join('\n');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Debug Information'),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: combinedInfo));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Center(
                                        child: Text('Copied to clipboard!'))),
                              );
                            }
                          },
                          child: Text(combinedInfo)),
                    ]))));
  }
}
