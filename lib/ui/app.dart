// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:radix_colors/radix_colors.dart';

import '../data/repositories/contacts.dart';
import '../tick.dart';
import '../veilid_init.dart';
import 'contact_list/page.dart';
import 'map/page.dart';
import 'profile/page.dart';
import 'settings/page.dart';
import 'updates/page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await changeWindowSetup(
    //       TitleBarStyle.hidden, OrientationCapability.normal);
    // });
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
              RadixColors.dark.plum.step4,
              RadixColors.dark.plum.step2,
            ])),
        child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Splash Screen
                      Expanded(
                          flex: 2,
                          child: SvgPicture.asset(
                            'assets/images/icon.svg',
                          )),
                      Expanded(
                          child: SvgPicture.asset(
                        'assets/images/title.svg',
                      ))
                    ]))),
      ));
}

class CoagulateApp extends StatelessWidget {
  const CoagulateApp({required this.contactsRepository, super.key});

  final ContactsRepository contactsRepository;

  @override
  Widget build(BuildContext context) => FutureProvider<VeilidChatGlobalInit?>(
      initialData: null,
      create: (context) async => VeilidChatGlobalInit.initialize(),
      builder: (context, child) {
        final globalInit = context.watch<VeilidChatGlobalInit?>();
        if (globalInit == null) {
          // Splash screen until we're done with init
          return Splash();
        }
        // Once init is done, we proceed with the app
        final localizationDelegate = LocalizedApp.of(context).delegate;

        // TODO: Add again:
        //LocalizationProvider(
        //  state: LocalizationProvider.of(context).state,
        //child: BackgroundTicker(
        //  child:
        return RepositoryProvider.value(
          value: contactsRepository,
          child: MaterialApp(
            title: 'Coagulate',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: CoagulateAppView(),
            localizationsDelegates: [localizationDelegate],
            supportedLocales: localizationDelegate.supportedLocales,
            locale: localizationDelegate.currentLocale,
          ),
        );
      });
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
          const SettingsPage(),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
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
