// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import '../circle_details/page.dart';
import '../contact_details/page.dart';
import '../widgets/scan_qr_code.dart';
import 'cubit.dart';

class ReceivedBatchInviteWidget extends StatefulWidget {
  const ReceivedBatchInviteWidget(
      {super.key, required this.batchName, required this.names});

  final String batchName;
  final Map<String, String> names;
  @override
  _ReceivedBatchInviteWidgetState createState() =>
      _ReceivedBatchInviteWidgetState();
}

class _ReceivedBatchInviteWidgetState extends State<ReceivedBatchInviteWidget> {
  String? _selectedNameId;

  @override
  void initState() {
    _selectedNameId = widget.names.keys.firstOrNull;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Invited via ${widget.batchName}'),
          actions: [
            IconButton(
                onPressed: context.read<ReceiveRequestCubit>().scanQrCode,
                icon: const Icon(Icons.qr_code_scanner))
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You have been invited in a batch with others. '
                          'Everyone in that batch gets to see each other. '
                          'As others use their invites, they appear automatically '
                          'as contacts and are added to your circle "${widget.batchName}", '
                          'which you can manage as usual and set what to share.'),
                      const SizedBox(height: 16),
                      // TODO: Handle no names available
                      const Text('Pick the name you want to share with others. '
                          'You can select more information to share later.'),
                      const SizedBox(height: 16),
                      DropdownMenu<String>(
                        initialSelection: _selectedNameId,
                        // requestFocusOnTap is enabled/disabled by platforms when it is null.
                        // On mobile platforms, this is false by default. Setting this to true will
                        // trigger focus request on the text field and virtual keyboard will appear
                        // afterward. On desktop platforms however, this defaults to true.
                        requestFocusOnTap: false,
                        label: const Text('Name'),
                        onSelected: (nameId) {
                          setState(() {
                            _selectedNameId = nameId;
                          });
                        },
                        dropdownMenuEntries: widget.names.entries
                            .map((e) =>
                                DropdownMenuEntry(label: e.value, value: e.key))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      // TODO: This also needs state to react to changes in selection;
                      // maybe not because it goes to processing state globally quite fast
                      Center(
                        child: FilledButton(
                          onPressed: (_selectedNameId == null)
                              ? null
                              : () async => context
                                  .read<ReceiveRequestCubit>()
                                  .handleBatchInvite(
                                      myNameId: _selectedNameId!),
                          child: const Text('Accept'),
                        ),
                      ),
                    ]))),
      );
}

// TODO: Move cubit initialization outside to parent scope (potentially leaving
// the BlocConsumer inside) instead of passing initial state here?
class ReceiveRequestPage extends StatelessWidget {
  const ReceiveRequestPage({super.key, this.initialState});

  final ReceiveRequestState? initialState;

  @override
  Widget build(BuildContext _) => BlocProvider(
      create: (context) => ReceiveRequestCubit(
          context.read<ContactsRepository>(),
          initialState: initialState),
      child: BlocConsumer<ReceiveRequestCubit, ReceiveRequestState>(
          listener: (context, state) async {
        if (state.status.isMalformedUrl) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Invalid URL')));
          context.read<ReceiveRequestCubit>().scanQrCode();
        } else if (state.status.isSuccess && state.profile != null) {
          await Navigator.of(context).pushAndRemoveUntil(
              ContactPage.route(state.profile!.coagContactId),
              (route) => route.isFirst);
        } else if (state.status.isBatchInviteSuccess) {
          // TODO: Remove redundancy by processing into state schema?
          final parts = state.fragment!.split('~');
          final recordKey = parts[parts.length - 4];
          await Navigator.of(context).pushAndRemoveUntil(
              CircleDetailsPage.route(recordKey), (route) => route.isFirst);
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
                        icon: const Icon(Icons.qr_code_scanner))
                  ],
                ),
                body: const Center(child: CircularProgressIndicator()));

          case ReceiveRequestStatus.handleBatchInvite:
            return ReceivedBatchInviteWidget(
                names: context
                        .read<ReceiveRequestCubit>()
                        .contactsRepository
                        .getProfileInfo()
                        ?.details
                        .names ??
                    {},
                // TODO: Allow ~ in name, by dropping the last couple splits and rejoining with ~
                batchName: state.fragment?.split('~').first ?? '???');

          case ReceiveRequestStatus.qrcode:
            return Scaffold(
              appBar: AppBar(title: const Text('Accept personal invite')),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: MediaQuery.sizeOf(context).width * 0.1,
                      right: MediaQuery.sizeOf(context).width * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: Instructions / re-request access if denied previously
                      const Text('Scan QR code:'),
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.center,
                          child: SizedBox.square(
                              dimension: MediaQuery.sizeOf(context).width * 0.8,
                              child: BarcodeScannerPageView(
                                  onDetectCallback: context
                                      .read<ReceiveRequestCubit>()
                                      .qrCodeCaptured))),
                      const SizedBox(height: 8),
                      const Text(
                          'Scan only QR codes that were specifically generated for you.'),
                      const SizedBox(height: 32),
                      const Text(
                          'Or if you have copied an invite to your clipboard:'),
                      const SizedBox(height: 8),
                      FilledButton(
                          onPressed:
                              context.read<ReceiveRequestCubit>().pasteInvite,
                          child: const Text('Paste invite')),
                      const SizedBox(height: 8),
                      const Text(
                          'Only paste invites that were specifically generated for you.'),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          case ReceiveRequestStatus.batchInviteConfirmed:
            return const Center(
                child: Text('Accepted, fetching contacts...', softWrap: true));
          case ReceiveRequestStatus.success:
          case ReceiveRequestStatus.batchInviteSuccess:
          case ReceiveRequestStatus.handleDirectSharing:
          case ReceiveRequestStatus.handleProfileLink:
          case ReceiveRequestStatus.malformedUrl:
          case ReceiveRequestStatus.handleSharingOffer:
            return const Center(child: CircularProgressIndicator());
        }
      }));
}
