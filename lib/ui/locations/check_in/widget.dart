// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/contacts.dart';
import 'cubit.dart';

class CheckInWidget extends StatelessWidget {
  const CheckInWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => CheckInCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<CheckInCubit, CheckInState>(
          listener: (context, state) async {},
          builder: (context, state) => ElevatedButton(
              // TODO: Display check in form with location (from gps, from map picker, from address, from coordinates) circles to share with, optional duration, optional move away to check out constraint
              onPressed: (context
                              .read<CheckInCubit>()
                              .contactsRepository
                              .profileContactId ==
                          null ||
                      state.checkingIn)
                  ? null
                  : () async {
                      await context.read<CheckInCubit>().checkIn(
                            // TODO: Get the remaining details from a user input form
                            name: 'Current Location',
                            details: '',
                            end: DateTime.now().add(Duration(hours: 2)),
                          );

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Checked in at current location for 2 hours')));
                    },
              child: (state.checkingIn)
                  ? Transform.scale(
                      scale: 0.5, child: const CircularProgressIndicator())
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Icon(Icons.pin_drop),
                          SizedBox(width: 8),
                          Text('check-in')
                        ]))));
}
