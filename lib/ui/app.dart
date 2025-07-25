// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/contact_location.dart';
import '../data/providers/distributed_storage/dht.dart';
import '../data/providers/persistent_storage/sqlite.dart';
import '../data/providers/system_contacts/system_contacts.dart';
import '../data/repositories/contacts.dart';
import '../data/repositories/settings.dart';
import '../l10n/app_localizations.dart';
import '../notification_service.dart';
import '../tick.dart';
import '../veilid_init.dart';
import 'circles_list/page.dart';
import 'contact_details/page.dart';
import 'contact_list/page.dart';
import 'import_ics/page.dart';
import 'locations/schedule/widget.dart';
import 'map/page.dart';
import 'profile/page.dart';
import 'receive_request/cubit.dart';
import 'receive_request/page.dart';
import 'settings/page.dart';
import 'welcome.dart';

// TODO: It seems odd to require the knowledge about which other route names should map to the relevant navigation items here
const navBarItems = [
  (
    '/',
    ['profile'],
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
  ),
  (
    '/circles',
    ['circles'],
    BottomNavigationBarItem(
        icon: Icon(Icons.bubble_chart_outlined), label: 'Circles')
  ),
  (
    '/contacts',
    [
      'contacts',
      'handleDirectSharing',
      'handleProfileLink',
      'handleSharingOffer',
      'handleBatchInvite',
      'contactDetails'
    ],
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
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  selectedFontSize: 12,
                  // Use index of the first level path member (also for nested paths)
                  currentIndex: (state.topRoute?.name == null)
                      ? 0
                      : (navBarItems.indexWhere(
                                  (i) => i.$2.contains(state.topRoute?.name)) ==
                              -1)
                          ? 0
                          : navBarItems.indexWhere(
                              (i) => i.$2.contains(state.topRoute?.name)),
                  showUnselectedLabels: true,
                  onTap: (i) => context.go(navBarItems[i].$1),
                ),
              ),
          routes: [
            GoRoute(
              path: '/',
              name: 'profile',
              builder: (_, __) => const ProfilePage(),
            ),
            GoRoute(
                path: '/circles',
                name: 'circles',
                builder: (_, __) => const CirclesListPage()),
            GoRoute(
                path: '/contacts',
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
                path: '/map',
                name: 'map',
                builder: (_, __) => const MapPage(),
                routes: [
                  GoRoute(
                      path: 'importIcs',
                      name: 'importIcs',
                      builder: (_, state) =>
                          ImportIcsPage(icsData: state.extra.toString())),
                  GoRoute(
                      path: 'scheduleLocation',
                      name: 'scheduleLocation',
                      // TODO: Handle if extra cannot be casted
                      builder: (_, state) => ScheduleWidget(
                          location: (state.extra == null)
                              ? null
                              : state.extra! as ContactTemporaryLocation)),
                ]),
            GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (_, __) => const SettingsPage()),
            GoRoute(
                path: '/c',
                name: 'handleDirectSharing',
                builder: (_, state) => ReceiveRequestPage(
                    initialState: ReceiveRequestState(
                        ReceiveRequestStatus.handleDirectSharing,
                        fragment: state.uri.fragment))),
            GoRoute(
                path: '/p',
                name: 'handleProfileLink',
                builder: (_, state) => ReceiveRequestPage(
                    initialState: ReceiveRequestState(
                        ReceiveRequestStatus.handleProfileLink,
                        fragment: state.uri.fragment))),
            GoRoute(
                path: '/o',
                name: 'handleSharingOffer',
                builder: (_, state) => ReceiveRequestPage(
                    initialState: ReceiveRequestState(
                        ReceiveRequestStatus.handleSharingOffer,
                        fragment: state.uri.fragment))),
            GoRoute(
                path: '/b',
                name: 'handleBatchInvite',
                builder: (_, state) => ReceiveRequestPage(
                    initialState: ReceiveRequestState(
                        ReceiveRequestStatus.handleBatchInvite,
                        fragment: state.uri.fragment))),
          ])
    ],
  );

  GoRouter get router => _router;
}

class CoagulateApp extends StatefulWidget {
  const CoagulateApp({super.key});

  @override
  _CoagulateAppState createState() => _CoagulateAppState();
}

class _CoagulateAppState extends State<CoagulateApp>
    with WidgetsBindingObserver {
  String? _providedNameOnFirstLaunch;

  final _seedColor = Colors.indigo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    unawaited(_checkFirstLaunch());

    // Configure background fetch
    unawaited(BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiredNetworkType: NetworkType.ANY,
          requiresBatteryNotLow: true,
        ), (String taskId) async {
      // This is the callback function that will be called periodically
      logDebug("[BackgroundFetch] Event received: $taskId");

      final log = <String>[];
      final startTime = DateTime.now();
      log.add('Start update to and from DHT at $startTime');

      // TODO: Passing an empty string for initial name seems hacky
      final repo = ContactsRepository(
          SqliteStorage(), VeilidDhtStorage(), SystemContacts(), '',
          initialize: false,
          notificationCallback: NotificationService().showNotification);

      // Await initialization with potential initial DHT updates unless it
      // exceeds 25s to respect the background task limit of 30s on iOS
      try {
        await repo
            .initialize(scheduleRegularUpdates: false)
            .timeout(const Duration(seconds: 25));
      } on TimeoutException {
        await BackgroundFetch.finish(taskId);
        return;
      }

      log.add('Initialization finished at at ${DateTime.now()}');

      await Future<void>.delayed(
          const Duration(seconds: 25) - DateTime.now().difference(startTime));

      log.add('Returning successfully after waiting until ${DateTime.now()}');

      logDebug('[BackgroundFetch] $log');

      // Signal completion of your task
      await BackgroundFetch.finish(taskId);
      return;
    }).then((int status) {
      logDebug('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      logDebug('[BackgroundFetch] configure ERROR: $e');
    }));

    // BackgroundFetch.scheduleTask(TaskConfig(
    //     taskId: 'com.foo.customtask',
    //     delay: 60000, // milliseconds
    //     forceAlarmManager: true));
  }

  Future<void> _checkFirstLaunch() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _providedNameOnFirstLaunch =
          sharedPreferences.getString('providedNameOnFirstLaunch') ?? '';
    });
  }

  Future<void> _setFirstLaunchComplete(
      {required String name, required String bootstrapUrl}) async {
    await SharedPreferences.getInstance().then((p) async {
      await p.setString('providedNameOnFirstLaunch', name);
      await p.setString('veilidBootstrapUrl', bootstrapUrl);
    });
    setState(() {
      _providedNameOnFirstLaunch = name;
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
      unawaited(BackgroundFetch.start().then((int status) {
        logDebug('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        logDebug('[BackgroundFetch] start ERROR: $e');
      }));
    } else if (state == AppLifecycleState.resumed) {
      // App comes to foreground
      unawaited(BackgroundFetch.stop().then((int status) {
        logDebug('[BackgroundFetch] stop success: $status');
      }).catchError((e) {
        logDebug('[BackgroundFetch] stop ERROR: $e');
      }));
    }
  }

  Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      logDebug('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  @override
  Widget build(BuildContext context) => FutureProvider<CoagulateGlobalInit?>(
      initialData: null,
      create: (context) async =>
          // TODO: Pass initially specified boostrap url
          CoagulateGlobalInit.initialize('bootstrap-v1.veilid.net'),
      // CoagulateGlobalInit.initialize can throw Already attached VeilidAPIException which is fine
      catchError: (context, error) => null,
      builder: (context, child) {
        final globalInit = context.watch<CoagulateGlobalInit?>();
        // Splash screen until we're done with init
        if (globalInit == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_providedNameOnFirstLaunch == null ||
            _providedNameOnFirstLaunch!.isEmpty) {
          return MaterialApp(
              title: 'Coagulate',
              debugShowCheckedModeBanner: true,
              themeMode: ThemeMode.system,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: _seedColor, brightness: Brightness.dark),
                useMaterial3: true,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: WelcomeScreen(_setFirstLaunchComplete));
        }

        // Once init is done, we proceed with the app
        return BackgroundTicker(
            child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
                create: (_) => SettingsRepository(
                    darkMode: MediaQuery.of(context).platformBrightness ==
                        Brightness.dark,
                    devicePixelRatio: View.of(context).devicePixelRatio)),
            RepositoryProvider(
                create: (context) => ContactsRepository(
                    SqliteStorage(),
                    VeilidDhtStorage(),
                    SystemContacts(),
                    _providedNameOnFirstLaunch!)),
          ],
          child: MaterialApp.router(
            title: 'Coagulate',
            debugShowCheckedModeBanner: true,
            themeMode: ThemeMode.system,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: _seedColor, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            routerDelegate: AppRouter().router.routerDelegate,
            routeInformationProvider:
                AppRouter().router.routeInformationProvider,
            routeInformationParser: AppRouter().router.routeInformationParser,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ));
      });
}
