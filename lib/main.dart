// Copyright 2024 Lukas Grossberger

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:coagulate/contact_list.dart';
import 'package:coagulate/contact_page.dart';

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
        appBar: AppBar(
          title: Text(_bottomNavigationItems.elementAt(_selectedIndex).label!),
        ),
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

class UpdatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
        children: List.generate(
          10,
          (index) => ListTile(
            title: Text('Update $index'),
          ),
        ),
      );
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // Get all contacts (lightly fetched)
      List<Contact> contacts = await FlutterContacts.getContacts();

      setState(() {
        _contacts = contacts.toList();
      });
    } else {
      print("Couldnt get contacts because of permission issues");
    }
  }

  @override
  Widget build(BuildContext context) => _contacts.isNotEmpty
      ? ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            Contact contact = _contacts[index];
            return ListTile(
              title: Text(contact.displayName ?? ''),
              // subtitle: Text(contact.phones.isNotEmpty
              //     ? contact.phones.first.value ?? ''
              //     : ''),
            );
          },
        )
      : const Center(
          child: Text('No contacts available.'),
        );
}

class MapPage extends StatelessWidget {
  // You can implement map view logic here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: This requires additional setup like permissions for iOS and API key for Android
      //       https://pub.dev/packages/platform_maps_flutter
      body: PlatformMap(
        initialCameraPosition: CameraPosition(
          target: const LatLng(47.6, 8.8796),
          zoom: 16.0,
        ),
        markers: Set<Marker>.of(
          [
            Marker(
              markerId: MarkerId('marker_1'),
              position: LatLng(47.6, 8.8796),
              consumeTapEvents: true,
              infoWindow: InfoWindow(
                title: 'PlatformMarker',
                snippet: "Hi I'm a Platform Marker",
              ),
              onTap: () {
                print("Marker tapped");
              },
            ),
          ],
        ),
        mapType: MapType.satellite,
        onTap: (location) => print('onTap: $location'),
        onCameraMove: (cameraUpdate) => print('onCameraMove: $cameraUpdate'),
        compassEnabled: true,
        onMapCreated: (controller) {
          Future.delayed(Duration(seconds: 2)).then(
            (_) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    bearing: 270.0,
                    target: LatLng(51.5160895, -0.1294527),
                    tilt: 30.0,
                    zoom: 18,
                  ),
                ),
              );
              controller
                  .getVisibleRegion()
                  .then((bounds) => print("bounds: ${bounds.toString()}"));
            },
          );
        },
      ),
    );
  }
}
