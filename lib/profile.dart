import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Contact? _profileContact;

  @override
  void initState() {
    super.initState();
    _pickContact();
  }

  Future<void> _pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var profileContactID = prefs.getString('profileContactID');

      if (profileContactID == null) {
        final contact = await FlutterContacts.openExternalPick();
        // TODO: Error handling
        var profileContactID = contact!.id;
        await prefs.setString('profileContactID', profileContactID);
      }

      // TODO: profileContactID is null after initial contact selection FIXME
      final contact = await FlutterContacts.getContact(profileContactID!);
      setState(() {
        // TODO: Error handling
        _profileContact = contact!;
      });
    } else {
      print("Couldnt get contacts because of permission issues");
    }
  }

  static const _textStyle = TextStyle(fontSize: 19);

  @override
  Widget build(
    BuildContext context,
  ) =>
      (_profileContact == null)
          ? Text("no profile contact stored")
          : Scaffold(
              appBar: AppBar(
                title: Text("Profile"),
              ),
              body: CustomScrollView(slivers: [
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                              margin: EdgeInsets.only(
                                  left: 20.0, right: 20.0, bottom: 20.0),
                              child: SizedBox(
                                  child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(children: [
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: avatar(_profileContact!)),
                                        Text(
                                          _profileContact!.displayName,
                                          style: _textStyle,
                                        ),
                                      ])))),
                          if (_profileContact!.phones.isNotEmpty)
                            Card(
                                margin: EdgeInsets.all(20.0),
                                child: SizedBox(
                                    child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(children: [
                                          Icon(Icons.phone),
                                          ..._profileContact!.phones.map((e) =>
                                              Text(
                                                  '${e.label.name.toUpperFirstCase()}: ${e.number}',
                                                  style: _textStyle))
                                        ])))),
                          if (_profileContact!.emails.isNotEmpty)
                            Card(
                                margin: EdgeInsets.all(20.0),
                                child: SizedBox(
                                    child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(children: [
                                          Icon(Icons.email),
                                          ..._profileContact!.emails.map((e) =>
                                              Text(
                                                  '${e.label.name.toUpperFirstCase()}: ${e.address}',
                                                  style: _textStyle))
                                        ])))),
                          if (_profileContact!.addresses.isNotEmpty)
                            Card(
                                margin: EdgeInsets.all(20.0),
                                child: SizedBox(
                                    child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(children: [
                                          Icon(Icons.home),
                                          ..._profileContact!.addresses.map(
                                              (e) => Text(
                                                  '${e.label.name.toUpperFirstCase()}: ${e.address}',
                                                  style: _textStyle))
                                        ])))),
                        ]))
              ]));
}
