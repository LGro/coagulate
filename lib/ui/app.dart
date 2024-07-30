// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/providers/distributed_storage/dht.dart';
import '../data/providers/persistent_storage/sqlite.dart';
import '../data/providers/system_contacts/system_contacts.dart';
import '../data/repositories/contacts.dart';
import '../tick.dart';
import '../veilid_init.dart';
import 'contact_details/page.dart';
import 'contact_list/page.dart';
import 'locations/page.dart';
import 'map/page.dart';
import 'profile/page.dart';
import 'receive_request/cubit.dart';
import 'receive_request/page.dart';
import 'settings/page.dart';
import 'updates/page.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
              Colors.white,
              Colors.white,
            ])),
        child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

// TODO: It seems odd to require the knowledge about which other route names should map to the relevant navigation items here
const navBarItems = [
  (
    '/',
    ['profile'],
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
  ),
  (
    '/locations',
    ['locations'],
    BottomNavigationBarItem(icon: Icon(Icons.pin_drop), label: 'Locations')
  ),
  (
    '/updates',
    ['updates'],
    BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Updates')
  ),
  (
    '/contacts',
    ['contacts', 'receiveRequest', 'contactDetails'],
    BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts')
  ),
  (
    '/map',
    ['map'],
    BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map')
  ),
  (
    '/settings',
    ['settings'],
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
  ),
];

class AppRouter {
  static final GoRouter _router = GoRouter(
    routes: [
      ShellRoute(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context, state, child) => Scaffold(
                body: child,
                bottomNavigationBar: BottomNavigationBar(
                  items: navBarItems.map((i) => i.$3).asList(),
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 12,
                  // Use index of the first level path member (also for nested paths)
                  currentIndex: (state.topRoute?.name == null)
                      ? 0
                      : navBarItems.indexWhere(
                          (i) => i.$2.contains(state.topRoute?.name)),
                  showUnselectedLabels: true,
                  onTap: (i) async =>
                      context.pushReplacement(navBarItems[i].$1),
                ),
              ),
          routes: [
            GoRoute(
                path: '/',
                name: 'profile',
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                      path: 'locations',
                      name: 'locations',
                      builder: (_, __) => const LocationsPage()),
                  GoRoute(
                      path: 'updates',
                      name: 'updates',
                      builder: (_, __) => const UpdatesPage()),
                  GoRoute(
                      path: 'contacts',
                      name: 'contacts',
                      builder: (_, __) => const ContactListPage(),
                      routes: [
                        GoRoute(
                            path: 'details/:coagContactId',
                            name: 'contactDetails',
                            builder: (_, state) => ContactPage(
                                coagContactId:
                                    state.pathParameters['coagContactId']!)),
                      ]),
                  GoRoute(
                      path: 'map',
                      name: 'map',
                      builder: (_, __) => const MapPage()),
                  GoRoute(
                      path: 'settings',
                      name: 'settings',
                      builder: (_, __) => const SettingsPage()),
                  GoRoute(
                      // TODO: Figure out how to handle language on coagulate.social so that we don't need to add the language to the links
                      path: 'en/c',
                      name: 'receiveRequest',
                      builder: (_, state) => ReceiveRequestPage(
                          initialState: ReceiveRequestState(
                              ReceiveRequestStatus.receivedUriFragment,
                              fragment: state.uri.fragment))),
                ])
          ])
    ],
  );

  GoRouter get router => _router;
}

class CoagulateApp extends StatefulWidget {
  @override
  _CoagulateAppState createState() => _CoagulateAppState();
}

class _CoagulateAppState extends State<CoagulateApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Configure background fetch
    // TODO: https://github.com/transistorsoft/flutter_background_fetch/blob/master/help/INSTALL-IOS.md
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiredNetworkType: NetworkType.ANY,
          requiresBatteryNotLow: true,
        ), (String taskId) async {
      // This is the callback function that will be called periodically
      print("[BackgroundFetch] Event received: $taskId");

      final log = <String>[];
      final startTime = DateTime.now();
      log.add('Start update to and from DHT at $startTime');

      final repo = ContactsRepository(
          SqliteStorage(), VeilidDhtStorage(), SystemContacts(),
          initialize: false);

      // Await initialization with potential initial DHT updates unless it
      // exceeds 25s to respect the background task limit of 30s on iOS
      try {
        await repo.initialize().timeout(const Duration(seconds: 25));
      } on TimeoutException {
        await BackgroundFetch.finish(taskId);
        return;
      }

      log.add('Initialization finished at at ${DateTime.now()}');

      await Future<void>.delayed(
          const Duration(seconds: 25) - DateTime.now().difference(startTime));

      log.add('Returning successfully after waiting until ${DateTime.now()}');

      print('[BackgroundFetch] $log');

      // Signal completion of your task
      await BackgroundFetch.finish(taskId);
      return;
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App goes to background
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start ERROR: $e');
      });
    } else if (state == AppLifecycleState.resumed) {
      // App comes to foreground
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] stop ERROR: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureProvider<VeilidChatGlobalInit?>(
      initialData: null,
      create: (context) async => VeilidChatGlobalInit.initialize(),
      builder: (context, child) {
        final globalInit = context.watch<VeilidChatGlobalInit?>();
        // Splash screen until we're done with init
        if (globalInit == null) {
          return const Splash();
        }

        // Once init is done, we proceed with the app
        return BackgroundTicker(
            child: RepositoryProvider.value(
          value: ContactsRepository(
              SqliteStorage(), VeilidDhtStorage(), SystemContacts()),
          child: MaterialApp.router(
            title: 'Coagulate',
            themeMode: ThemeMode.system,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            routerDelegate: AppRouter().router.routerDelegate,
            routeInformationProvider:
                AppRouter().router.routeInformationProvider,
            routeInformationParser: AppRouter().router.routeInformationParser,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('de')],
          ),
        ));
      });
}
