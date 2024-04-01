// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import '../../tick.dart';
import '../contact_list/page.dart';
import '../map/page.dart';
import '../profile/page.dart';
import 'updates.dart';
import '../recieve_request/page.dart';

class CoagulateApp extends StatelessWidget {
  const CoagulateApp({required this.contactsRepository, super.key});

  final ContactsRepository contactsRepository;

  @override
  Widget build(BuildContext context) => BackgroundTicker(
      builder: (context) => RepositoryProvider.value(
            value: contactsRepository,
            child: MaterialApp(
              title: 'Coagulate',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: CoagulateAppView(),
            ),
          ));
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
          const ProfilePage(),
          const UpdatesPage(),
          const ContactListPage(),
          const MapPage(),
        ].elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            // TODO: Move profile selection to initial startup launch screen and then hide in settings?
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
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      );
}
