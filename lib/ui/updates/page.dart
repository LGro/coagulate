// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import 'cubit.dart';

String formatTimeDifference(Duration d) {
  if (d.isNegative || d < const Duration(minutes: 1)) {
    return 'now';
  }
  if (d < const Duration(hours: 1)) {
    return '${d.inMinutes}m';
  }
  if (d < const Duration(days: 1)) {
    return '${d.inHours}h';
  }
  return '${d.inDays}d';
}

Widget updateTile(String name, String timing, String change) => ListTile(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
        Text(timing, style: const TextStyle(color: Colors.black54))
      ],
    ),
    subtitle: Row(
      children: [
        // TODO: Use flexible for old and new value to trim them both dynamically
        // Or use Expanded for dynamic multiline
        Flexible(child: Text(change, overflow: TextOverflow.ellipsis))
      ],
    ));

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
      ),
      body: BlocProvider(
          create: (context) => UpdatesCubit(context.read<ContactsRepository>()),
          child: BlocConsumer<UpdatesCubit, UpdatesState>(
              listener: (context, state) async {},
              builder: (context, state) => RefreshIndicator(
                  onRefresh: context.read<UpdatesCubit>().refresh,
                  child: ListView(
                    children: (state.updates.isEmpty)
                        ? [
                            Container(
                                padding: const EdgeInsets.all(20),
                                child: const Text(
                                    'No updates yet, share with others or ask others to share with you!',
                                    style: TextStyle(fontSize: 16)))
                          ]
                        : state.updates
                            .map((u) => updateTile(
                                'Update!',
                                formatTimeDifference(
                                    DateTime.now().difference(u.timestamp)),
                                u.message))
                            .toList(),
                    // // TODO: On tap bring to contact details
                    // updateTile(
                    //     'Ronja Dudeli van Makolle Longname The Fourth',
                    //     '(today)',
                    //     'Name: Timo => Ronja Dudeli van Makolle Longname The Fourth'),
                    // // TODO: On tap bring to map, centered around location with time slider at right time
                    // updateTile('Ronja Dudeli', '(4 days)',
                    //     'Will be near Hamburg, 2024-10-21 till 2024-10-28'),
                    // updateTile(
                    //     'Ronja Dudeli', '(5 days)', 'Started sharing with you'),
                    // updateTile('Timo Dudeli', '(1 month)',
                    //     'Home: Heimsheimer St... => Burgstraße 21, 81992 Heidelberg'),
                    // updateTile('Helli Schmudela', '(2 years)',
                    //     'Work: +3011311411 => +2144242200'),
                  )))));
}
