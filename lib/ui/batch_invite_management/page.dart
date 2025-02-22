// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'cubit.dart';

class BatchInvitesPage extends StatefulWidget {
  const BatchInvitesPage({super.key});

  @override
  _BatchInvitesPageState createState() => _BatchInvitesPageState();
}

class _BatchInvitesPageState extends State<BatchInvitesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _invitationsAmountController =
      TextEditingController();
  DateTime? _selectedDate;
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _invitationsAmountController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    _isButtonEnabled.value = _nameController.text.trim().isNotEmpty &&
        _invitationsAmountController.text.trim().isNotEmpty &&
        _selectedDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _invitationsAmountController.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _updateButtonState();
    }
  }

  Widget _body(BuildContext context, BatchInvitesState state) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('With batch invites, everyone invited via the same batch '
              'will see the label and everyone else invited to the '
              'batch to connect with them before the invites expire.'),
          const SizedBox(height: 16),
          const Text('New batch',
              textScaler: TextScaler.linear(1.2),
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                flex: 4,
                child: TextField(
                  controller: _nameController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      labelText: 'Label', border: OutlineInputBorder()),
                )),
            const SizedBox(width: 4),
            Expanded(
                flex: 2,
                child: TextField(
                  controller: _invitationsAmountController,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Invitations', border: OutlineInputBorder()),
                )),
            const SizedBox(width: 4),
            Expanded(
                flex: 3,
                child: TextField(
                  onTap: _pickDate,
                  controller: TextEditingController(
                      text: (_selectedDate == null)
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                  autocorrect: false,
                  decoration: const InputDecoration(
                      labelText: 'Expiration', border: OutlineInputBorder()),
                )),
          ]),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
              valueListenable: _isButtonEnabled,
              builder: (_, isEnabled, child) => Center(
                  child: FilledButton(
                      onPressed: (!isEnabled)
                          ? null
                          : () async => context
                              .read<BatchInvitesCubit>()
                              .generateInvites(
                                  _nameController.text.trim(),
                                  int.tryParse(_invitationsAmountController.text
                                          .trim()) ??
                                      0,
                                  _selectedDate!),
                      child: const Text('Prepare invite')))),

          const SizedBox(height: 16),

          const Text(
            'Existing batches',
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2),
          ),
          // Trigger share dialogue with comma separated links
          Expanded(
              child: ListView.builder(
                  itemCount: state.batches.length,
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: existingBatchWidget(state.batches[index])))),

          // const Text(
          //     'The functionality to expire existing batches, '
          //     'and to see how many invites were used will follow soon.'),
        ],
      ));

  @override
  Widget build(BuildContext _) => Scaffold(
      appBar: AppBar(
        title: const Text('Batch invites'),
      ),
      body: BlocProvider(
          create: (context) => BatchInvitesCubit(),
          child: BlocBuilder<BatchInvitesCubit, BatchInvitesState>(
              builder: _body)));
}

String generateInviteLinks(Batch batch) => batch.subkeyWriters
    .toList()
    .asMap()
    .entries
    .map(
        // The index of the writer in the list + 1 is the corresponding subkey
        // TODO: Do we need to URL encode? Maybe use Url().toString()?
        (w) => 'https://coagulate.social/c/${batch.label}'
            '#${batch.dhtRecordKey}:${batch.psk}:${w.key + 1}:${w.value}')
    .join(', ');

Widget existingBatchWidget(Batch batch) => Row(children: [
      Text(batch.label),
      const SizedBox(width: 4),
      Text('(${DateFormat('yyyy-MM-dd').format(batch.expiration)})'),
      const SizedBox(width: 4),
      IconButton.filledTonal(
          // Share.shareXFiles([XFile.fromData(utf8.encode(text), mimeType: 'text/plain')], fileNameOverrides: ['myfile.txt']),
          onPressed: () async => Share.share(generateInviteLinks(batch)),
          icon: const Icon(Icons.share)),
    ]);
