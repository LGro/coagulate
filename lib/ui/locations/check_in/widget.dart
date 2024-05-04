// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import '../../../data/models/contact_location.dart';
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
                      final location = await Location().getLocation();

                      if (location.longitude == null ||
                          location.latitude == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Current GPS location unavailable')));
                        return;
                      }

                      await context.read<CheckInCubit>().checkIn(
                          ContactTemporaryLocation(
                              // TODO: That's not the most ideal way, is it?
                              coagContactId: context
                                  .read<CheckInCubit>()
                                  .contactsRepository
                                  .profileContactId!,
                              longitude: location.longitude!,
                              latitude: location.latitude!,
                              start: DateTime.now(),
                              // TODO: Get the remaining details from a user input form
                              name: 'Current Location',
                              details: '',
                              end: DateTime.now().add(Duration(hours: 2)),
                              checkedIn: true));

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Checked in at current location for 2 hours')));
                    },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.pin_drop),
                const SizedBox(width: 8),
                if (state.checkingIn)
                  const CircularProgressIndicator()
                else
                  const Text('check-in')
              ]))));
}
