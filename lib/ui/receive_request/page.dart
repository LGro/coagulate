// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../profile/page.dart';
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
                        TextButton(
                            onPressed:
                                context.read<ReceiveRequestCubit>().scanQrCode,
                            child: const Text('Cancel'))
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
                        TextButton(
                            onPressed:
                                context.read<ReceiveRequestCubit>().scanQrCode,
                            child: const Text('Cancel'))
                      ],
                    ),
                    body: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // TODO: Propose matching contact
                        // TODO: Display proper profile
                        Text(state.profile!.details!.displayName),
                        if (state.profile!.details!.phones.isNotEmpty)
                          phones(state.profile!.details!.phones),
                        if (state.profile!.details!.emails.isNotEmpty)
                          emails(state.profile!.details!.emails),
                        TextButton(
                            onPressed: context
                                .read<ReceiveRequestCubit>()
                                .linkExistingContact,
                            child: const Text('Link existing contact')),
                        TextButton(
                            onPressed: context
                                .read<ReceiveRequestCubit>()
                                .createNewContact,
                            child: const Text('Create new contact')),
                      ],
                    )));
            }
          }));
}
