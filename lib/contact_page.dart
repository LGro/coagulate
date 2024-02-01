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

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'proto/proto.dart' as proto;

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
  Contact contact;
  PassContactPage(Contact this.contact);
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  static const routeName = '/contactPage';

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with AfterLayoutMixin<ContactPage> {
  Contact? _contact;

  @override
  void afterFirstLayout(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PassContactPage;
    setState(() {
      _contact = args.contact;
    });
    _fetchContact();
  }

  Future _fetchContact() async {
    // First fetch all contact details
    await _fetchContactWith(highRes: false);

    // Then fetch contact with high resolution photo
    await _fetchContactWith(highRes: true);
  }

  Future _fetchContactWith({required bool highRes}) async {
    final contact = await FlutterContacts.getContact(
      _contact!.id,
      withThumbnail: !highRes,
      withPhoto: highRes,
      withGroups: true,
      withAccounts: true,
    );
    setState(() {
      _contact = contact;
    });
  }

  Widget _body() {
    if (_contact?.name == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withSpacing([
          Center(child: avatar(_contact!)),
          _makeCard(
              'ID',
              [_contact!],
              (x) => [
                    Divider(),
                    Text('ID: ${x.id}'),
                    Text('Display name: ${x.displayName}'),
                    Text('Starred: ${x.isStarred}'),
                  ]),
          _makeCard(
              'Name',
              [_contact!.name],
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
          if (_contact!.phones.isNotEmpty)
            _makeCard(
                'Phones',
                _contact!.phones,
                (x) => [
                      Divider(),
                      Text('Number: ${x.number}'),
                      Text('Normalized number: ${x.normalizedNumber}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                      Text('Primary: ${x.isPrimary}')
                    ]),
          if (_contact!.emails.isNotEmpty)
            _makeCard(
                'Emails',
                _contact!.emails,
                (x) => [
                      Divider(),
                      Text('Address: ${x.address}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                      Text('Primary: ${x.isPrimary}')
                    ]),
          if (_contact!.addresses.isNotEmpty)
            _makeCard(
                'Addresses',
                _contact!.addresses,
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
          if (_contact!.organizations.isNotEmpty)
            _makeCard(
                'Organizations',
                _contact!.organizations,
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
          if (_contact!.websites.isNotEmpty)
            _makeCard(
                'Websites',
                _contact!.websites,
                (x) => [
                      Divider(),
                      Text('URL: ${x.url}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                    ]),
          if (_contact!.socialMedias.isNotEmpty)
            _makeCard(
                'Social medias',
                _contact!.socialMedias,
                (x) => [
                      Divider(),
                      Text('Value: ${x.userName}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                    ]),
          if (_contact!.events.isNotEmpty)
            _makeCard(
                'Events',
                _contact!.events,
                (x) => [
                      Divider(),
                      // Text('Date: ${_formatDate(x)}'),
                      Text('Label: ${x.label}'),
                      Text('Custom label: ${x.customLabel}'),
                    ]),
          if (_contact!.notes.isNotEmpty)
            _makeCard(
                'Notes',
                _contact!.notes,
                (x) => [
                      Divider(),
                      Text('Note: ${x.note}'),
                    ]),
          if (_contact!.groups.isNotEmpty)
            _makeCard(
                'Groups',
                _contact!.groups,
                (x) => [
                      Divider(),
                      Text('Group ID: ${x.id}'),
                      Text('Name: ${x.name}'),
                    ]),
          if (_contact!.accounts.isNotEmpty)
            _makeCard(
                'Accounts',
                _contact!.accounts,
                (x) => [
                      Divider(),
                      Text('Raw IDs: ${x.rawId}'),
                      Text('Type: ${x.type}'),
                      Text('Name: ${x.name}'),
                      Text('Mimetypes: ${x.mimetypes}'),
                    ]),
          _makeCard(
              'Raw JSON',
              [_contact!],
              (x) => [
                    Divider(),
                    Text(prettyJson(
                        x.toJson(withThumbnail: false, withPhoto: false))),
                  ]),
          // TODO: Check whether there is already a DHT location and shared secret stored;
          // if not, display a button "Connect" first, that on tap writes to DHT and then
          // displays the QR Code, URI and NFC options
          _makeCard(
            "Connect via QR Code",
            [_contact!],
            (x) => [
              Center(
                  child: QrImageView(
                data: 'coag://locationKeyDHT-sharedSecret',
                version: QrVersions.auto,
                size: 200.0,
              ))
            ],
          ),
          _makeCard(
            "Connect via Link",
            [_contact!],
            (x) => [Center(child: Text("coag://locationKeyDHT-sharedSecret"))],
          ),
          _makeCard(
            "Connect via NFC",
            [_contact!],
            (x) => [
              Center(
                  child: TextButton(
                onPressed: () {},
                child: Text("Activate NFC"),
              ))
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
  Widget build(BuildContext context) {
    return _body();
  }

  // void async _publishProfileForContact() {
  //     final protoMessage = proto.Message()
  //       ..author = localAccount.identityMaster
  //           .identityPublicTypedKey()
  //           .toProto()
  //       ..timestamp = (await eventualVeilid.future).now().toInt64()
  //       ..text = "Message!"
  //       ..signature = signature;

  //     final message = protoMessageToMessage(protoMessage);

  //     final localConversationRecordKey = proto.TypedKeyProto.fromProto(
  //         widget.activeChatContact.localConversationRecordKey);
  //     final remoteIdentityPublicKey = proto.TypedKeyProto.fromProto(
  //         widget.activeChatContact.identityPublicKey);

  // final messagesRecordKey =
  //     proto.TypedKeyProto.fromProto(protoMessage);
  // final crypto = await getConversationCrypto(
  //     activeAccountInfo: activeAccountInfo,
  //     remoteIdentityPublicKey: remoteIdentityPublicKey);
  // final writer = getConversationWriter(activeAccountInfo: activeAccountInfo);

  // await (await DHTShortArray.openWrite(messagesRecordKey, writer,
  //         parent: localConversationRecordKey, crypto: crypto))
  //     .scope((messages) async {
  //   await messages.tryAddItem(message.writeToBuffer());
  // });

  //     ref.invalidate(activeConversationMessagesProvider);
  // }
}
