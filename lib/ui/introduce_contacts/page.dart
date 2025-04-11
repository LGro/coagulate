// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../utils.dart';
import 'cubit.dart';

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
                    const SizedBox(height: 16),
                    Center(
                        child: FilledButton(
                            onPressed: (_contactA == null || _contactB == null)
                                ? null
                                : () async => context
                                    .read<IntroduceContactsCubit>()
                                    .introduce(
                                        contactIdA: _contactA!.coagContactId,
                                        nameA: _asControllerA.text,
                                        contactIdB: _contactB!.coagContactId,
                                        nameB: _asControllerB.text,
                                        message: _message)
                                    .then((_) => (context.mounted)
                                        ? Navigator.of(context).pop()
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
