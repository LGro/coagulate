// Copyright 2024 Lukas Grossberger
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'cubit/peer_contact_cubit.dart';
import 'cubit/profile_contact_cubit.dart';
import 'profile.dart';

Widget avatar(Contact contact,
    [double radius = 48.0, IconData defaultIcon = Icons.person]) {
  if (contact.photoOrThumbnail != null) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact.photoOrThumbnail!),
      radius: radius,
    );
  }
  return CircleAvatar(
    radius: radius,
    child: Icon(defaultIcon),
  );
}

class PassContactPage {
  String contactId;
  PassContactPage(String this.contactId);
}

class ContactPage extends StatelessWidget {
  const ContactPage({required this.contactId});

  final String contactId;

  Widget _body(BuildContext context, PeerContact? contact) {
    if (contact?.contact.name == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: avatar(contact!.contact)),
          BlocConsumer<ProfileContactCubit, ProfileContactState>(
              listener: (context, state) async {},
              builder: (context, state) => (state.profileContact == null)
                  ? const Card(
                      child: Text(
                          'Need to pick profile contact before coagulate.'))
                  : Card(
                      child: Center(
                          child: (contact.sharingProfile == 'dont' ||
                                  contact.sharingProfile == null)
                              ? TextButton(
                                  onPressed: () async => {
                                        context
                                            .read<PeerContactCubit>()
                                            .shareWithPeer(contact.contact.id,
                                                state.profileContact!)
                                      },
                                  child: const Text('Coagulate'))
                              : TextButton(
                                  onPressed: () async => {
                                        context
                                            .read<PeerContactCubit>()
                                            .unshareWithPeer(contact.contact.id)
                                      },
                                  child: const Text('Dissolve'))))),
          if (contact.contact.phones.isNotEmpty) phones(contact.contact.phones),
          if (contact.contact.emails.isNotEmpty) emails(contact.contact.emails),
          if (contact.contact.addresses.isNotEmpty)
            addresses(context, contact.contact.addresses, null),
          // TODO: Switch to drop down selection when profiles are ready
          //  DropdownButton(
          //   // TODO make state dependent
          //   value: (c.sharingProfile == null) ? 'dont' : c.sharingProfile ,
          //   // TODO: Get from my profile preferences
          //   items: [
          //     DropdownMenuItem<String>(child: Text("Nothing"), value: "dont"),
          //     DropdownMenuItem<String>(child: Text("Friends"), value: "friends"),
          //     DropdownMenuItem<String>(child: Text("Work"), value: "work"),
          //     ],
          //   onChanged: (v) => context.read<PeerContactCubit>().updateContact(
          //     c.contact.id as String, v! as String))]),
          if (contact.myRecord == null &&
              contact.peerRecord == null &&
              contact.sharingProfile != null &&
              contact.sharingProfile != "dont")
            // const Text('No connection; share dialog QR, NFC etc.'),
            _makeCard(
              'Connect via QR Code',
              [contact],
              (x) => [
                Center(
                    child: QrImageView(
                  data: 'coag://locationKeyDHT-sharedSecret',
                  version: QrVersions.auto,
                  size: 200.0,
                ))
              ],
            ),
          if (contact.myRecord == null &&
              contact.peerRecord != null &&
              contact.sharingProfile != null &&
              contact.sharingProfile != "dont")
            // const Text('They shared; share back dialog'),
            _makeCard(
              'Connect via QR Code',
              [contact],
              (x) => [
                Center(
                    child: QrImageView(
                  data: 'coag://locationKeyDHT-sharedSecret',
                  version: QrVersions.auto,
                  size: 200.0,
                ))
              ],
            ),
          if (contact.myRecord != null &&
              contact.peerRecord != null &&
              contact.sharingProfile != null &&
              contact.sharingProfile != "dont")
            const Text('Full on coagulation; success!'),
          if (contact.myRecord != null &&
              contact.sharingProfile != null &&
              contact.sharingProfile != "dont")
            const Text('I am sharing; stop or change sharing dialog'),
          _makeCard(
            'Connect via NFC',
            [contact],
            (x) => [
              Center(
                  child: TextButton(
                onPressed: () {},
                child: const Text('Activate NFC'),
              )),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    final spacer = SizedBox(height: 8);
    return <Widget>[spacer] +
        widgets.map((p) => [p, spacer]).expand((p) => p).toList();
  }

  Card _makeCard(
      String title, List fields, List<Widget> Function(dynamic) mapper) {
    var elements = <Widget>[];
    fields.forEach((field) => elements.addAll(mapper(field)));
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _withSpacing(<Widget>[
                Text(title, style: TextStyle(fontSize: 22)),
              ] +
              elements),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => PeerContactCubit()),
            BlocProvider(create: (context) => ProfileContactCubit())
          ],
          child: BlocConsumer<PeerContactCubit, PeerContactState>(
              listener: (context, state) async {},
              builder: (context, state) => _body(context,
                  (contactId == null) ? null : state.contacts[contactId])));
}
