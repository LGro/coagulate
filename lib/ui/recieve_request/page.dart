// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubit/profile_cubit.dart';
import '../../data/repositories/contacts.dart';
import '../../data/models/coag_contact.dart';
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
              case RecieveRequestStatus.pickMode:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Pick Mode'),
                    ),
                    body: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().scanQrCode,
                            child: const Text('Scan QR Code')),
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().readNfcTag,
                            child: const Text('Read NFC')),
                      ],
                    )));

              case RecieveRequestStatus.nfc:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Read NFC'),
                      actions: [
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().pickMode,
                            child: Text('Cancel'))
                      ],
                    ),
                    body: const Column(
                      children: [],
                    ));

              case RecieveRequestStatus.qrcode:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Scan QR Code'),
                      actions: [
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().pickMode,
                            child: Text('Cancel'))
                      ],
                    ),
                    body: BarcodeScannerPageView(
                        onDetectCallback: context
                            .read<RecieveRequestCubit>()
                            .qrCodeCaptured));

              case RecieveRequestStatus.paste:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Paste Link'),
                      actions: [
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().pickMode,
                            child: const Text('Cancel'))
                      ],
                    ),
                    body: Column(
                      children: [],
                    ));

              case RecieveRequestStatus.recieved:
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Received Contact'),
                      actions: [
                        TextButton(
                            onPressed:
                                context.read<RecieveRequestCubit>().pickMode,
                            child: const Text('Cancel'))
                      ],
                    ),
                    body: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Received:\n${state.profile!}'),
                        TextButton(
                            onPressed: () => {},
                            child: const Text('Link existing contact')),
                        TextButton(
                            onPressed: () => {},
                            child: const Text('Create new contact')),
                      ],
                    )));
            }
          }));
}
