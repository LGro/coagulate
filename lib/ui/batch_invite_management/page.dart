// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../utils.dart';
import '../widgets/dht_status/widget.dart';
import 'cubit.dart';

class BatchInvitesPage extends StatefulWidget {
  const BatchInvitesPage({super.key});

  @override
  _BatchInvitesPageState createState() => _BatchInvitesPageState();
}

class _BatchInvitesPageState extends State<BatchInvitesPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  final _amountFieldKey = GlobalKey<FormFieldState>();
  final _expirationFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _invitationsAmountController =
      TextEditingController();
  final TextEditingController _expirationController = TextEditingController();
  DateTime? _selectedDate;
  bool _readyToSubmit = false;

  String? validateLabel(String? value) {
    if (value != null && !RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value)) {
      return 'Label includes special characters, '
          'only use letters and numbers.';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      return 'Not a valid number';
    }
    if (parsedValue > 100) {
      return 'We are limited to 100 invites right now. '
          'Contact the Coagulate team if you need more.';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _invitationsAmountController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _readyToSubmit = _nameController.text.trim().isNotEmpty &&
          _invitationsAmountController.text.trim().isNotEmpty &&
          _selectedDate != null &&
          validateLabel(_nameController.text) == null &&
          validateAmount(_invitationsAmountController.text) == null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _invitationsAmountController.dispose();
    _expirationController.dispose();
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
      _expirationController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      _updateButtonState();
    }
  }

  void _resetForm() {
    _nameController.text = '';
    _invitationsAmountController.text = '';
    _selectedDate = null;
    _expirationController.text = '';
    _readyToSubmit = false;
  }

  Widget _body(BuildContext context, BatchInvitesState state) =>
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                  'Do you want to invite a bunch of folks from an existing '
                  'community who already do or want to know each other?'),
              const Text(
                  'With invitation batches, everyone invited via the same '
                  'batch will see the label and everyone else invited to the '
                  'batch to connect with them before the invites expire.'),
              const SizedBox(height: 16),
              Text('New batch',
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              TextFormField(
                key: _labelFieldKey,
                controller: _nameController,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Batch label',
                    border: OutlineInputBorder(),
                    helperMaxLines: 100,
                    errorMaxLines: 100,
                    helperText:
                        'Only alpha numeric characters i.e. letters and '
                        'numbers are allowed'),
                validator: validateLabel,
                onChanged: (label) => _labelFieldKey.currentState?.validate(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: _amountFieldKey,
                controller: _invitationsAmountController,
                autocorrect: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Invitations',
                    border: OutlineInputBorder(),
                    helperMaxLines: 100,
                    errorMaxLines: 100,
                    helperText:
                        'Number of invitations in the batch. Pick a handful '
                        'more than you think, since you can not generate any '
                        'more later'),
                validator: validateAmount,
                onChanged: (label) => _amountFieldKey.currentState?.validate(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: _expirationFieldKey,
                onTap: _pickDate,
                controller: _expirationController,
                readOnly: true,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Expiration date',
                    border: OutlineInputBorder(),
                    helperMaxLines: 100,
                    helperText:
                        'Until this date, everyone needs to have used their '
                        'invitation.'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                  onPressed: (!_readyToSubmit)
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          await context
                              .read<BatchInvitesCubit>()
                              .generateInvites(
                                  _nameController.text.trim(),
                                  int.tryParse(_invitationsAmountController.text
                                          .trim()) ??
                                      0,
                                  _selectedDate!);
                          _resetForm();
                        },
                  child: const Text('Generate invites batch')),
              const SizedBox(height: 16),
              Text('Generated batches',
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const Text(
                  'WARNING: When you leave this view, you will no longer have '
                  'access to the batch you created. Make sure to wait until '
                  'the status changed from pending to synced and then copy / '
                  'save the generated invitation batch links directly.'),
              const SizedBox(height: 8),
              ...state.batches.values
                  .map((b) => existingBatchWidget(context, b)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext _) => Scaffold(
      appBar: AppBar(title: const Text('Invitation batches')),
      body: BlocProvider(
          create: (context) => BatchInvitesCubit(),
          child: BlocBuilder<BatchInvitesCubit, BatchInvitesState>(
              builder: _body)));
}

Widget existingBatchWidget(BuildContext context, Batch batch) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Batch "${batch.label}"',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      Row(children: [
        Text('Due date ${DateFormat('yyyy-MM-dd').format(batch.expiration)}, '),
        DhtStatusWidget(recordKey: batch.dhtRecordKey, statusWidgets: const {}),
      ]),
      Row(children: [
        FilledButton.tonal(
            onPressed: () async {
              final links = generateBatchInviteLinks(batch).join(', ');
              await Clipboard.setData(ClipboardData(text: links));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Links copied to clipboard')),
              );
            },
            child: const Row(children: [
              Icon(Icons.copy),
              SizedBox(width: 8),
              Text('Copy links'),
              SizedBox(width: 2),
            ])),
        const SizedBox(width: 4),
        FilledButton.tonal(
            onPressed: () async => SharePlus.instance.share(ShareParams(files: [
                  XFile.fromData(
                      utf8.encode(generateBatchInviteLinks(batch).join(', ')),
                      mimeType: 'text/plain')
                ], fileNameOverrides: [
                  'coagulate_batch_${batch.label}.txt'
                ])),
            child: const Row(children: [
              Icon(Icons.save),
              SizedBox(width: 8),
              Text('Save links'),
              SizedBox(width: 2),
            ])),
      ]),
    ]);
