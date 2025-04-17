// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/repositories/contacts.dart';
import '../introduce_contacts/page.dart';
import '../utils.dart';
import 'cubit.dart';

class IntroductionsPage extends StatelessWidget {
  const IntroductionsPage({super.key});

  List<Widget> _noIntroductionsBody(BuildContext context) => [
        Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
                'Nobody has introduced you to any of their contacts yet.',
                style: TextStyle(fontSize: 16))),
        const SizedBox(height: 16),
        FilledButton(
            onPressed: () async => Navigator.of(context).push(
                MaterialPageRoute<IntroduceContactsPage>(
                    builder: (context) => const IntroduceContactsPage())),
            child: const Text('Make an introduction'))
      ];

  List<Widget> _introductionsBody(BuildContext context,
          Iterable<(CoagContact, ContactIntroduction)> introductions) =>
      introductions
          .map(
            (intro) => ListTile(
              title: Text('${intro.$2.otherName} via ${intro.$1.name}',
                  softWrap: true),
              subtitle: (intro.$2.message == null)
                  ? null
                  : Text(intro.$2.message!, softWrap: true),
              onTap: () async => showDialog<void>(
                context: context,
                builder: (alertContext) => AlertDialog(
                  titlePadding:
                      const EdgeInsets.only(left: 16, right: 16, top: 16),
                  title: Text('Accept introduction to '
                      '${intro.$2.otherName}'),
                  actions: [
                    const SizedBox(height: 4),
                    Center(
                        child: FilledButton.tonal(
                            onPressed: alertContext.pop,
                            child: const Text('Cancel'))),
                    const SizedBox(height: 4),
                    Center(
                        child: FilledButton(
                            onPressed: () async {
                              final coagContactId = await context
                                  .read<IntroductionsCubit>()
                                  .accept(intro.$1, intro.$2);
                              if (context.mounted) {
                                context.goNamed('contactDetails',
                                    pathParameters: {
                                      'coagContactId': coagContactId
                                    });
                                alertContext.pop();
                              }
                            },
                            child: const Text('Accept & configure sharing'))),
                  ],
                ),
              ),
            ),
          )
          .toList();

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
              builder: (context, state) {
                final introductions =
                    pendingIntroductions(state.contacts.values);
                return ListView(
                    children:
                        pendingIntroductions(state.contacts.values).isEmpty
                            ? _noIntroductionsBody(context)
                            : _introductionsBody(context, introductions));
              }),
        ),
      );
}
