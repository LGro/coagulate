// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import '../widgets/scan_qr_code.dart';
import 'cubit.dart';

class RecieveRequestPage extends StatelessWidget {
  const RecieveRequestPage({super.key});

  // TODO: Use initial status when provided
  static Route<void> route(RecieveRequestStatus? initialStatus) =>
      MaterialPageRoute(
          fullscreenDialog: true, builder: (_) => RecieveRequestPage());

  @override
  Widget build(BuildContext _) => BlocProvider(
      create: (context) =>
          RecieveRequestCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<RecieveRequestCubit, RecieveRequestState>(
          listener: (context, state) async {},
          builder: (context, state) {
            switch (state.status) {
              case RecieveRequestStatus.processing:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Processing...'),
                    ),
                    body: const Center(
                        child: Column(
                      children: [CircularProgressIndicator()],
                    )));

              case RecieveRequestStatus.qrcode:
                return Scaffold(
                    appBar: AppBar(title: const Text('Scan QR Code')),
                    body: BarcodeScannerPageView(
                        onDetectCallback: context
                            .read<RecieveRequestCubit>()
                            .qrCodeCaptured));

              case RecieveRequestStatus.received:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Received Contact'),
                      actions: [
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().scanQrCode,
                            child: const Text('Cancel'))
                      ],
                    ),
                    body: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // TODO: Propose matching contact
                        Text('Received:\n${state.profile!}'),
                        TextButton(
                            onPressed: context
                                .read<RecieveRequestCubit>()
                                .linkExistingContact,
                            child: const Text('Link existing contact')),
                        TextButton(
                            onPressed: context
                                .read<RecieveRequestCubit>()
                                .createNewContact,
                            child: const Text('Create new contact')),
                      ],
                    )));
            }
          }));
}
