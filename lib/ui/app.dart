// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:radix_colors/radix_colors.dart';
import 'package:workmanager/workmanager.dart';

import '../data/providers/background.dart';
import '../data/repositories/contacts.dart';
import '../tick.dart';
import '../veilid_init.dart';
import 'contact_list/page.dart';
import 'map/page.dart';
import 'profile/page.dart';
import 'settings/page.dart';
import 'updates/page.dart';

const String updateToAndFromDhtTaskName = 'social.coagulate.dht.refresh';
const String refreshProfileContactTaskName = 'social.coagulate.profile.refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, __) async {
    if (task == refreshProfileContactTaskName) {
      return refreshProfileContactDetails();
    }
    if (task == updateToAndFromDhtTaskName) {
      return updateToAndFromDht();
    }
    return true;
  });
}

Future<void> _registerBackgroundTasks() async {
  await Workmanager().cancelAll();
  await Workmanager().registerPeriodicTask(
    refreshProfileContactTaskName,
    refreshProfileContactTaskName,
    initialDelay: const Duration(seconds: 20),
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
  await Workmanager().registerPeriodicTask(
    updateToAndFromDhtTaskName,
    updateToAndFromDhtTaskName,
    initialDelay: const Duration(seconds: 40),
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

class Splash extends StatelessWidget {
  const Splash({super.key});

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
  const CoagulateApp({required this.contactsRepositoryPath, super.key});

  final String contactsRepositoryPath;

  @override
  Widget build(BuildContext context) => FutureProvider<VeilidChatGlobalInit?>(
      initialData: null,
      create: (context) async {
        // TODO: Is this the right place to initialize the workmanager?
        await Workmanager()
            .initialize(callbackDispatcher, isInDebugMode: kDebugMode);
        await _registerBackgroundTasks();
        return VeilidChatGlobalInit.initialize();
      },
      builder: (context, child) {
        final globalInit = context.watch<VeilidChatGlobalInit?>();
        // Splash screen until we're done with init
        if (globalInit == null) {
          return const Splash();
        }
        // Once init is done, we proceed with the app
        final localizationDelegate = LocalizedApp.of(context).delegate;
        return LocalizationProvider(
            state: LocalizationProvider.of(context).state,
            child: BackgroundTicker(
                child: RepositoryProvider.value(
              // TODO: Where to async initialize instead?
              value: ContactsRepository(contactsRepositoryPath),
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
            )));
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
