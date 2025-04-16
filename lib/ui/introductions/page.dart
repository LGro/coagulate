// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/contacts.dart';
import '../utils.dart';
import 'cubit.dart';

class IntroductionsPage extends StatelessWidget {
  const IntroductionsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Introductions'),
        ),
        body: BlocProvider(
          create: (context) =>
              IntroductionsCubit(context.read<ContactsRepository>()),
          child: BlocConsumer<IntroductionsCubit, IntroductionsState>(
            listener: (context, state) async {},
            builder: (context, state) => ListView(
              children: state.contacts.isEmpty
                  ? [
                      Container(
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                              'Nobody has introduced you to any of their contacts yet.',
                              style: TextStyle(fontSize: 16)))
                    ]
                  : pendingIntroductions(state.contacts.values)
                      .map((intro) => ListTile(
                            title: Text(
                                '${intro.$2.otherName} via ${intro.$1.name}',
                                softWrap: true),
                            subtitle: (intro.$2.message == null)
                                ? null
                                : Text(intro.$2.message!, softWrap: true),
                            onTap: () async => showDialog<void>(
                              context: context,
                              builder: (alertContext) => AlertDialog(
                                titlePadding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
                                title: Text(
                                    'Accept introduction to ${intro.$2.otherName}'),
                                actions: [
                                  FilledButton.tonal(
                                      onPressed: alertContext.pop,
                                      child: const Text('Cancel')),
                                  FilledButton(
                                      onPressed: () async {
                                        final coagContactId = await context
                                            .read<IntroductionsCubit>()
                                            .accept(intro.$1, intro.$2);
                                        if (context.mounted) {
                                          context.goNamed('contactDetails',
                                              pathParameters: {
                                                'coagContactId': coagContactId
                                              });
                                        }
                                      },
                                      child: const Text(
                                          'Accept & configure sharing')),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
            ),
          ),
        ),
      );
}
