// Adapted from the MIT Licensed https://github.com/QuisApp/flutter_contacts/tree/master/example_full/lib/pages

/*
MIT License

Copyright (c) 2020 Joachim Valente

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'cubit/peer_contact_cubit.dart';
import 'cubit/profile_contact_cubit.dart';

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
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withSpacing([
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
                                        context.read<PeerContactCubit>().shareWithPeer(
                                            contact.contact.id,
                                            // Profile probably comes in here fully
                                            // constructed to allow filtering it inside
                                            // depending on sharing preference
                                            state.profileContact!.displayName)
                                      },
                                  child: const Text('Coagulate'))
                              : TextButton(
                                  onPressed: () async => {
                                        context
                                            .read<PeerContactCubit>()
                                            .unshareWithPeer(contact.contact.id)
                                      },
                                  child: const Text('Dissolve'))))),
          _makeCard(
              'ID',
              [contact!.contact],
              (x) => [
                    Divider(),
                    Text('ID: ${x.id}'),
                    Text('Display name: ${x.displayName}'),
                    Text('Starred: ${x.isStarred}'),
                  ]),
          _makeCard(
              'Name',
              [contact!.contact.name],
              (x) => [
                    Divider(),
                    Text('Prefix: ${x.prefix}'),
                    Text('First: ${x.first}'),
                    Text('Middle: ${x.middle}'),
                    Text('Last: ${x.last}'),
                    Text('Suffix: ${x.suffix}'),
                    Text('Nickname: ${x.nickname}'),
                    Text('Phonetic first: ${x.firstPhonetic}'),
                    Text('Phonetic middle: ${x.middlePhonetic}'),
                    Text('Phonetic last: ${x.lastPhonetic}'),
                  ]),
          if (contact!.contact.phones.isNotEmpty)
            _makeCard(
                'Phones',
                contact!.contact.phones,
                (x) => [
                      Divider(),
                      Text('Number: ${x.number}'),
                      Text('Normalized number: ${x.normalizedNumber}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                      Text('Primary: ${x.isPrimary}')
                    ]),
          if (contact!.contact.emails.isNotEmpty)
            _makeCard(
                'Emails',
                contact!.contact.emails,
                (x) => [
                      Divider(),
                      Text('Address: ${x.address}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                      Text('Primary: ${x.isPrimary}')
                    ]),
          if (contact!.contact.addresses.isNotEmpty)
            _makeCard(
                'Addresses',
                contact!.contact.addresses,
                (x) => [
                      Divider(),
                      Text('Address: ${x.address}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                      Text('Street: ${x.street}'),
                      Text('PO box: ${x.pobox}'),
                      Text('Neighborhood: ${x.neighborhood}'),
                      Text('City: ${x.city}'),
                      Text('State: ${x.state}'),
                      Text('Postal code: ${x.postalCode}'),
                      Text('Country: ${x.country}'),
                      Text('ISO country: ${x.isoCountry}'),
                      Text('Sub admin area: ${x.subAdminArea}'),
                      Text('Sub locality: ${x.subLocality}'),
                    ]),
          if (contact!.contact.organizations.isNotEmpty)
            _makeCard(
                'Organizations',
                contact!.contact.organizations,
                (x) => [
                      Divider(),
                      Text('Company: ${x.company}'),
                      Text('Title: ${x.title}'),
                      Text('Department: ${x.department}'),
                      Text('Job description: ${x.jobDescription}'),
                      Text('Symbol: ${x.symbol}'),
                      Text('Phonetic name: ${x.phoneticName}'),
                      Text('Office location: ${x.officeLocation}'),
                    ]),
          if (contact!.contact.websites.isNotEmpty)
            _makeCard(
                'Websites',
                contact!.contact.websites,
                (x) => [
                      Divider(),
                      Text('URL: ${x.url}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                    ]),
          if (contact!.contact.socialMedias.isNotEmpty)
            _makeCard(
                'Social medias',
                contact!.contact.socialMedias,
                (x) => [
                      Divider(),
                      Text('Value: ${x.userName}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                    ]),
          if (contact!.contact.events.isNotEmpty)
            _makeCard(
                'Events',
                contact!.contact.events,
                (x) => [
                      Divider(),
                      // Text('Date: ${_formatDate(x)}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                    ]),
          if (contact!.contact.notes.isNotEmpty)
            _makeCard(
                'Notes',
                contact!.contact.notes,
                (x) => [
                      Divider(),
                      Text('Note: ${x.note}'),
                    ]),
          if (contact!.contact.groups.isNotEmpty)
            _makeCard(
                'Groups',
                contact!.contact.groups,
                (x) => [
                      Divider(),
                      Text('Group ID: ${x.id}'),
                      Text('Name: ${x.name}'),
                    ]),
          if (contact!.contact.accounts.isNotEmpty)
            _makeCard(
                'Accounts',
                contact!.contact.accounts,
                (x) => [
                      Divider(),
                      Text('Raw IDs: ${x.rawId}'),
                      Text('Type: ${x.type}'),
                      Text('Name: ${x.name}'),
                      Text('Mimetypes: ${x.mimetypes}'),
                    ]),
          _makeCard(
              'Raw JSON',
              [contact!.contact],
              (x) => [
                    Divider(),
                    Text(prettyJson(
                        x.toJson(withThumbnail: false, withPhoto: false))),
                  ]),
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
              "Connect via QR Code",
              [contact!],
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
              "Connect via QR Code",
              [contact!],
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
            "Connect via NFC",
            [contact!],
            (x) => [
              Center(
                  child: TextButton(
                onPressed: () {},
                child: const Text('Activate NFC'),
              )),
            ],
          )
        ]),
      ),
    );
  }

  String _formatDate(Event e) =>
      '${e.year?.toString()?.padLeft(4, '0') ?? '--'}/'
      '${e.month.toString().padLeft(2, '0')}/'
      '${e.day.toString().padLeft(2, '0')}';

  List<Widget> _withSpacing(List<Widget> widgets) {
    final spacer = SizedBox(height: 8);
    return <Widget>[spacer] +
        widgets.map((p) => [p, spacer]).expand((p) => p).toList();
  }

  Card _makeCard(
      String title, List fields, List<Widget> Function(dynamic) mapper) {
    var elements = <Widget>[];
    fields?.forEach((field) => elements.addAll(mapper(field)));
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
