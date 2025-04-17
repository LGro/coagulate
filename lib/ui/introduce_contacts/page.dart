// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../utils.dart';
import 'cubit.dart';

bool alreadyKnowEachOther(CoagContact? c1, CoagContact? c2) =>
    c1 != null &&
    c2 != null &&
    (c1.knownPersonalContactIds.contains(c2.theirPersonalUniqueId) ||
        c2.knownPersonalContactIds.contains(c1.theirPersonalUniqueId));

class IntroduceContactsPage extends StatefulWidget {
  const IntroduceContactsPage({super.key});

  @override
  State<StatefulWidget> createState() => _IntroduceContactsPageState();
}

class _IntroduceContactsPageState extends State<IntroduceContactsPage> {
  final _formKey = GlobalKey<FormState>();

  final _asControllerA = TextEditingController();
  final _asControllerB = TextEditingController();

  CoagContact? _contactA;
  CoagContact? _contactB;
  String? _message;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Make an introduction'),
      ),
      body: BlocProvider(
        create: (context) =>
            IntroduceContactsCubit(context.read<ContactsRepository>()),
        child: BlocConsumer<IntroduceContactsCubit, IntroduceContactsState>(
          listener: (context, state) => {},
          builder: (context, state) => SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Introduce')),
                    Row(children: [
                      Expanded(
                          child: Autocomplete<CoagContact>(
                        fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) =>
                            TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: 'Contact',
                                    border: OutlineInputBorder()),
                                onFieldSubmitted: (_) => onFieldSubmitted()),
                        optionsBuilder: (textEditingValue) =>
                            (textEditingValue.text == '')
                                ? []
                                : state.contacts.where((contact) =>
                                    searchMatchesContact(
                                        textEditingValue.text, contact) &&
                                    contact.coagContactId !=
                                        _contactB?.coagContactId),
                        onSelected: (c) => setState(() {
                          _contactA = c;
                          _asControllerA.text = c.name;
                        }),
                        displayStringForOption: (c) => c.name,
                      )),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('as')),
                      Expanded(
                          child: TextFormField(
                        controller: _asControllerA,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Alias',
                            border: OutlineInputBorder()),
                      )),
                    ]),
                    // TODO: Move into validator instead
                    if (_contactA != null &&
                        _contactA!.dhtSettings.theirPublicKey == null)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                              'You are not fully connected with that contact '
                              'yet, which is required for making an '
                              'introduction. Try again in a while.')),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('and')),
                    Row(children: [
                      Expanded(
                          child: Autocomplete<CoagContact>(
                        fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) =>
                            TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: 'Contact',
                                    border: OutlineInputBorder()),
                                onFieldSubmitted: (_) => onFieldSubmitted()),
                        optionsBuilder: (textEditingValue) =>
                            (textEditingValue.text == '')
                                ? []
                                : state.contacts.where((contact) =>
                                    searchMatchesContact(
                                        textEditingValue.text, contact) &&
                                    contact.coagContactId !=
                                        _contactA?.coagContactId),
                        onSelected: (c) => setState(() {
                          _contactB = c;
                          _asControllerB.text = c.name;
                        }),
                        displayStringForOption: (c) => c.name,
                      )),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('as')),
                      Expanded(
                          child: TextFormField(
                        controller: _asControllerB,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Alias',
                            border: OutlineInputBorder()),
                      )),
                    ]),
                    // TODO: Move into validator instead
                    if (_contactB != null &&
                        _contactB!.dhtSettings.theirPublicKey == null)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                              'You are not fully connected with that contact '
                              'yet, which is required for making an '
                              'introduction. Try again in a while.')),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('with')),
                    TextFormField(
                        onChanged: (m) => setState(() {
                              _message = m;
                            }),
                        autocorrect: false,
                        maxLines: 6,
                        decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Message',
                            border: OutlineInputBorder())),
                    if (alreadyKnowEachOther(_contactA, _contactB))
                      const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('They already know each other :)')),
                    const SizedBox(height: 16),
                    Center(
                        child: FilledButton(
                            onPressed: (_contactA?.dhtSettings.theirPublicKey ==
                                        null ||
                                    _contactB?.dhtSettings.theirPublicKey ==
                                        null ||
                                    alreadyKnowEachOther(_contactA, _contactB))
                                ? null
                                : () async => context
                                    .read<IntroduceContactsCubit>()
                                    .introduce(
                                        contactIdA: _contactA!.coagContactId,
                                        nameA: _asControllerA.text,
                                        contactIdB: _contactB!.coagContactId,
                                        nameB: _asControllerB.text,
                                        message: _message)
                                    .then((success) => (context.mounted)
                                        ? (success
                                            ? Navigator.of(context).pop()
                                            : ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Creating introduction failed'),
                                              )))
                                        : null),
                            child: const Text('Introduce them'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
}
