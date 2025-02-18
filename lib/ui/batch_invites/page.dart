// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'cubit.dart';

class BatchInvitesPage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Batch invites'),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'With batch invites, everyone invited via the same batch '
                  'will see the label and everyone else from the batch to '
                  'connect with them until the invites expire.'),
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
                          labelText: 'Invitations',
                          border: OutlineInputBorder()),
                    )),
                const SizedBox(width: 4),
                Expanded(
                    flex: 3,
                    child: TextField(
                      onTap: _pickDate,
                      controller: TextEditingController(
                          text: (_selectedDate == null)
                              ? ''
                              : DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate!)),
                      autocorrect: false,
                      decoration: const InputDecoration(
                          labelText: 'Expiration',
                          border: OutlineInputBorder()),
                    )),
              ]),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                  valueListenable: _isButtonEnabled,
                  builder: (context, isEnabled, child) => Align(
                      alignment: Alignment.center,
                      child: FilledButton(
                          onPressed: (!isEnabled)
                              ? null
                              : () => context
                                  .read<BatchInvitesCubit>()
                                  .generateInvites(
                                      _nameController.text.trim(),
                                      int.tryParse(_invitationsAmountController
                                              .text
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
              const Text(
                  'The functionality to extend or expire existing batches, '
                  'and to see how many invites were used will follow soon.'),
            ],
          )));
}
