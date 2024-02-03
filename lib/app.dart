// Copyright 2024 Lukas Grossberger
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'contact_list.dart';
import 'contact_page.dart';
import 'map.dart';
import 'profile.dart';
import 'updates.dart';

class CoagulateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Coagulate',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CoagulateAppView(),
        // https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
        routes: {
          ContactPage.routeName: (context) => const ContactPage(),
        },
      );
}

class CoagulateAppView extends StatefulWidget {
  @override
  _CoagulateAppViewState createState() => _CoagulateAppViewState();
}

class _CoagulateAppViewState extends State<CoagulateAppView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: [
          ProfilePage(),
          UpdatesPage(),
          ContactListPage(),
          MapPage(),
        ].elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
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
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.deepPurpleAccent,
          onTap: _onItemTapped,
        ),
      );
}
