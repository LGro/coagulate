// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../utils.dart';
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
  final TextEditingController _expirationController = TextEditingController();
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
  }

  Widget _body(BuildContext context, BatchInvitesState state) =>
      SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                  'Do you want to invite a bunch of folks from an existing '
                  'community who already do or want to know each other?'),
              const Text(
                  'With invitation batches, everyone invited via the same batch '
                  'will see the label and everyone else invited to the '
                  'batch to connect with them before the invites expire.'),
              const SizedBox(height: 16),
              Text('New batch',
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              TextField(
                  controller: _nameController,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9]*$')),
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Batch label',
                      border: OutlineInputBorder(),
                      helperMaxLines: 100,
                      helperText:
                          'Only alpha numeric characters i.e. letters and '
                          'numbers are allowed')),
              const SizedBox(height: 16),
              TextField(
                  controller: _invitationsAmountController,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Invitations',
                      border: OutlineInputBorder(),
                      helperMaxLines: 100,
                      helperText:
                          'Number of invitations in the batch. Pick a handful '
                          'more than you think, since you can not generate any '
                          'more later')),
              const SizedBox(height: 16),
              TextField(
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
                          'invitation.')),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                  valueListenable: _isButtonEnabled,
                  builder: (_, isEnabled, child) => Center(
                      child: FilledButton(
                          onPressed: (!isEnabled)
                              ? null
                              : () async {
                                  await context
                                      .read<BatchInvitesCubit>()
                                      .generateInvites(
                                          _nameController.text.trim(),
                                          int.tryParse(
                                                  _invitationsAmountController
                                                      .text
                                                      .trim()) ??
                                              0,
                                          _selectedDate!);
                                  _resetForm();
                                },
                          child: const Text('Generate invites batch')))),
              const SizedBox(height: 16),
              Text('Generated batches',
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const Text(
                  'WARNING: When you leave this view, you will no longer have '
                  'access to the batch you created. Make sure to copy / export '
                  'the generated invitation batches links directly.'),
              ...state.batches.values.map(existingBatchWidget),
            ],
          ));

  @override
  Widget build(BuildContext _) => Scaffold(
      appBar: AppBar(title: const Text('Invitation batches')),
      body: BlocProvider(
          create: (context) => BatchInvitesCubit(),
          child: BlocBuilder<BatchInvitesCubit, BatchInvitesState>(
              builder: _body)));
}

Widget existingBatchWidget(Batch batch) => Row(children: [
      Text(batch.label),
      const SizedBox(width: 4),
      Text('(${DateFormat('yyyy-MM-dd').format(batch.expiration)})'),
      const SizedBox(width: 4),
      IconButton.filledTonal(
          // Share.shareXFiles([XFile.fromData(utf8.encode(text), mimeType: 'text/plain')], fileNameOverrides: ['myfile.txt']),
          onPressed: () async =>
              Share.share(generateBatchInviteLinks(batch).join(', ')),
          icon: const Icon(Icons.share)),
    ]);
