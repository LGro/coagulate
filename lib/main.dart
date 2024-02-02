// Copyright 2024 Lukas Grossberger

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact_list.dart';
import 'contact_page.dart';
import 'map.dart';
import 'updates.dart';
import 'profile.dart';

void main() {
  runApp(MyApp());
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
        // bottomSheet: TabBar(tabs: [Text("Hi")]),
        bottomNavigationBar: BottomNavigationBar(
          items: _bottomNavigationItems,
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.deepPurpleAccent,
          onTap: _onItemTapped,
        ),
      );
}
