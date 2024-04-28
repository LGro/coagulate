// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

              case ReceiveRequestStatus.received:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Received Contact'),
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
                        // TODO: Propose matching contact
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
                        Expanded(
                            child: ListView(
                          children: state.contactProporsalsForLinking
                              .where((c) => c.details != null)
                              .map((c) => ListTile(
                                  leading: avatar(c.systemContact, radius: 18),
                                  title: Text(c.details!.displayName),
                                  //trailing: Text(_contactSyncStatus(c)),
                                  onTap: () => context
                                      .read<ReceiveRequestCubit>()
                                      .linkExistingContact(c)))
                              .toList(),
                        )),
                        TextButton(
                            onPressed:
                                context.read<ReceiveRequestCubit>().scanQrCode,
                            child: const Text('Cancel')),
                      ],
                    )));
            }
          }));
}
