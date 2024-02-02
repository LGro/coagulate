// Copyright 2024 Lukas Grossberger

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact_list.dart';
import 'contact_page.dart';
import 'map.dart';
import 'updates.dart';

void main() {
  runApp(MyApp());
}

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Navigation App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
        // https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
        routes: {
          ContactPage.routeName: (context) => ContactPage(),
        },
      );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const _bottomNavigationItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.update),
      label: 'Updates',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.contacts),
      label: 'Contacts',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ),
  ];

  static final List<Widget> _widgetOptions = <Widget>[
    ProfilePage(),
    UpdatesPage(),
    ContactListPage(),
    MapPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: AppBar(
        //   title: Text(_bottomNavigationItems.elementAt(_selectedIndex).label!),
        // ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: _bottomNavigationItems,
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.deepPurpleAccent,
          onTap: _onItemTapped,
        ),
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

  @override
  Widget build(BuildContext context) => (_profileContact == null)
      ? Text("no profile contact stored")
      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          avatar(_profileContact!),
          Text(
            _profileContact!.displayName,
            style: TextStyle(fontSize: 20),
          ),
          Text(
              'Phone number: ${_profileContact!.phones.isNotEmpty ? _profileContact!.phones.first.number : '(none)'}'),
          Text(
              'Email address: ${_profileContact!.emails.isNotEmpty ? _profileContact!.emails.first.address : '(none)'}'),
        ]);
}
