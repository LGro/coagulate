// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../profile/page.dart';
import '../widgets/avatar.dart';
import '../widgets/scan_qr_code.dart';
import 'cubit.dart';

class ReceiveRequestPage extends StatelessWidget {
  const ReceiveRequestPage({super.key, this.initialState});

  // TODO: Use initial status when provided
  static Route<void> route(ReceiveRequestStatus? initialStatus) =>
      MaterialPageRoute(
          fullscreenDialog: true, builder: (_) => const ReceiveRequestPage());

  final ReceiveRequestState? initialState;

  @override
  Widget build(BuildContext _) => BlocProvider(
      create: (context) => ReceiveRequestCubit(
          context.read<ContactsRepository>(),
          initialState: initialState),
      child: BlocConsumer<ReceiveRequestCubit, ReceiveRequestState>(
          listener: (context, state) async {
        if (state.status.isSuccess) {
          await Navigator.of(context)
              .pushReplacement(ContactPage.route(state.profile!));
        }
      }, builder: (context, state) {
        switch (state.status) {
          case ReceiveRequestStatus.processing:
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Processing...'),
                  actions: [
                    IconButton(
                        onPressed:
                            context.read<ReceiveRequestCubit>().scanQrCode,
                        icon: const Icon(Icons.qr_code))
                  ],
                ),
                body: const Center(child: CircularProgressIndicator()));

          case ReceiveRequestStatus.qrcode:
            return Scaffold(
                appBar: AppBar(title: const Text('Scan QR Code')),
                body: BarcodeScannerPageView(
                    onDetectCallback:
                        context.read<ReceiveRequestCubit>().qrCodeCaptured));

          case ReceiveRequestStatus.receivedRequest:
            return Scaffold(
                // TODO: Theme
                backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                appBar: AppBar(
                  title: const Text('Received Request'),
                  actions: [
                    IconButton(
                        onPressed:
                            context.read<ReceiveRequestCubit>().scanQrCode,
                        icon: const Icon(Icons.qr_code))
                  ],
                ),
                body: Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      const Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text('Someone asks you to share your profile '
                              'with them. If you already have them in your '
                              'contacts, pick the matching one, or enter '
                              'their name to create a new contact.')),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 16),
                          child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Their Name',
                                  border: OutlineInputBorder()),
                              onChanged: context
                                  .read<ReceiveRequestCubit>()
                                  .updateNewRequesterContact)),
                      TextButton(
                          onPressed:
                              (state.profile?.details?.displayName.isEmpty ??
                                      true)
                                  ? null
                                  : context
                                      .read<ReceiveRequestCubit>()
                                      .createNewContact,
                          child: const Text(
                              'Create new contact & start sharing with them')),
                      if (state.contactProporsalsForLinking.isNotEmpty)
                        const Center(
                            child: Text(
                                'or pick an existing contact to start sharing with')),
                      const SizedBox(height: 12),
                      if (state.contactProporsalsForLinking.isNotEmpty)
                        _pickExisting(
                            context,
                            state.contactProporsalsForLinking,
                            context
                                .read<ReceiveRequestCubit>()
                                .linkExistingContactRequested),
                    ])));

          case ReceiveRequestStatus.receivedShare:
            return Scaffold(
                // TODO: Theme
                backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                appBar: AppBar(
                  title: const Text('Received Shared Contact'),
                  actions: [
                    IconButton(
                        onPressed:
                            context.read<ReceiveRequestCubit>().scanQrCode,
                        icon: const Icon(Icons.qr_code))
                  ],
                ),
                body: Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    if (state.profile?.details != null)
                      ...displayDetails(state.profile!.details!),
                    TextButton(
                        onPressed: context
                            .read<ReceiveRequestCubit>()
                            .createNewContact,
                        child: const Text('Create new contact')),
                    if (state.contactProporsalsForLinking.isNotEmpty)
                      const Center(
                          child: Text('or link to an existing contact')),
                    if (state.contactProporsalsForLinking.isNotEmpty)
                      _pickExisting(
                          context,
                          state.contactProporsalsForLinking,
                          context
                              .read<ReceiveRequestCubit>()
                              .linkExistingContactSharing),
                    TextButton(
                        onPressed:
                            context.read<ReceiveRequestCubit>().scanQrCode,
                        child: const Text('Cancel')),
                  ],
                )));

          case ReceiveRequestStatus.success:
            return const Center(child: CircularProgressIndicator());
        }
      }));
}

Widget _pickExisting(
        BuildContext context,
        Iterable<CoagContact> contactProporsalsForLinking,
        Future<void> Function(CoagContact contact) linkExistingCallback) =>
    Expanded(
        child: ListView(
      children: contactProporsalsForLinking
          // TODO: Filter out the profile contact
          .where((c) => c.details != null || c.systemContact != null)
          .map((c) => ListTile(
              leading: avatar(c.systemContact, radius: 18),
              title: Text(c.details?.displayName ??
                  c.systemContact?.displayName ??
                  '???'),
              //trailing: Text(_contactSyncStatus(c)),
              onTap: () => unawaited(linkExistingCallback(c))))
          .toList(),
    ));
