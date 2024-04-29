// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
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
  const ReceiveRequestPage({super.key});

  // TODO: Use initial status when provided
  static Route<void> route(ReceiveRequestStatus? initialStatus) =>
      MaterialPageRoute(
          fullscreenDialog: true, builder: (_) => const ReceiveRequestPage());

  @override
  Widget build(BuildContext _) => BlocProvider(
      create: (context) =>
          ReceiveRequestCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<ReceiveRequestCubit, ReceiveRequestState>(
          listener: (context, state) async {},
          builder: (context, state) {
            switch (state.status) {
              case ReceiveRequestStatus.processing:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Processing...'),
                    ),
                    body: Center(
                        child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        IconButton(
                            onPressed:
                                context.read<ReceiveRequestCubit>().scanQrCode,
                            icon: const Icon(Icons.qr_code))
                      ],
                    )));

              case ReceiveRequestStatus.qrcode:
                if (state.profile != null) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(ContactPage.route(state.profile!));
                }
                return Scaffold(
                    appBar: AppBar(title: const Text('Scan QR Code')),
                    body: BarcodeScannerPageView(
                        onDetectCallback: context
                            .read<ReceiveRequestCubit>()
                            .qrCodeCaptured));

              case ReceiveRequestStatus.receivedRequest:
                return Scaffold(
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
                              child: Text(
                                  'Someone asks you to share your profile '
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
                              onPressed: context
                                  .read<ReceiveRequestCubit>()
                                  .createNewContact,
                              child: const Text(
                                  'Create new contact & start sharing with them')),
                          const Center(
                              child: Text(
                                  'or pick an existing contact to start sharing with')),
                          const SizedBox(height: 12),
                          _pickExisting(
                              context, state.contactProporsalsForLinking),
                        ])));

              case ReceiveRequestStatus.receivedShare:
                return Scaffold(
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
                        // TODO: Display proper profile
                        Center(
                            child: Text(state.profile!.details!.displayName)),
                        if (state.profile!.details!.phones.isNotEmpty)
                          phones(state.profile!.details!.phones),
                        if (state.profile!.details!.emails.isNotEmpty)
                          emails(state.profile!.details!.emails),
                        TextButton(
                            onPressed: context
                                .read<ReceiveRequestCubit>()
                                .createNewContact,
                            child: const Text('Create new contact')),
                        const Center(
                            child: Text('or link to an existing contact')),
                        _pickExisting(
                            context, state.contactProporsalsForLinking),
                        TextButton(
                            onPressed:
                                context.read<ReceiveRequestCubit>().scanQrCode,
                            child: const Text('Cancel')),
                      ],
                    )));
            }
          }));
}

Widget _pickExisting(BuildContext context,
        Iterable<CoagContact> contactProporsalsForLinking) =>
    Expanded(
        child: ListView(
      children: contactProporsalsForLinking
          .where((c) => c.details != null)
          .map((c) => ListTile(
              leading: avatar(c.systemContact, radius: 18),
              title: Text(c.details!.displayName),
              //trailing: Text(_contactSyncStatus(c)),
              onTap: () =>
                  context.read<ReceiveRequestCubit>().linkExistingContact(c)))
          .toList(),
    ));
