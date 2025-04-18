// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid/veilid.dart';

import '../../data/repositories/contacts.dart';
import 'cubit.dart';

class BackupPage extends StatelessWidget {
  BackupPage({super.key});

  final _textFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Backup'),
        ),
        body: BlocProvider(
          create: (context) => RestoreCubit(context.read<ContactsRepository>()),
          child: BlocConsumer<RestoreCubit, RestoreState>(
            listener: (context, state) => {},
            builder: (blocContext, state) => SingleChildScrollView(
              child: Column(children: [
                const Text(
                    'Did you already use Coagulate before and have a backup '
                    'secret restore your profile and contacts?'),
                TextFormField(
                    key: _textFieldKey,
                    onChanged: (v) {
                      if (_textFieldKey.currentState?.validate() ?? false) {}
                    },
                    validator: (value) {
                      if (value == null) {
                        return null;
                      }
                      final splits = value.split('~');
                      if (splits.length != 2) {
                        return 'Invalid backup secret.';
                      }
                      try {
                        Typed<FixedEncodedString43>.fromString(splits.first);
                        FixedEncodedString43.fromString(splits.last);
                      } on Exception {
                        return 'Invalid backup secret.';
                      }
                    }),
              ]),
            ),
          ),
        ),
      );
}
