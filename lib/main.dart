// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'bloc_observer.dart';
import 'tools/loggy.dart';
import 'ui/app.dart';

const String dhtRefreshBackgroundTaskName = 'social.coagulate.dht.refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task == dhtRefreshBackgroundTaskName) {
      // TODO: Ensure veilid is running
      // TODO: Wait for a reasonable amount of seconds if not connected to enough nodes
      // TODO: If still not connected enough, cancel
      // TODO: Update contacts from DHT records and persist; order by least recently updated or random?
      // TODO: After 30 seconds, stop
    }
    return Future.value(true);
  });
}

void _showNoPermission(
    BuildContext context, BackgroundRefreshPermissionState hasPermission) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: const Text('No permission'),
              content:
                  Text('Background app refresh is disabled, please enable in '
                      'App settings. Status ${hasPermission.name}'),
              actions: <Widget>[
                TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop()),
              ]));
}

Future<void> _initWorkManager(BuildContext context) async {
  if (Platform.isIOS) {
    final hasPermission =
        await Workmanager().checkBackgroundRefreshPermission();
    if (hasPermission != BackgroundRefreshPermissionState.available) {
      return _showNoPermission(context, hasPermission);
    }
  }
  // TODO: Check if already initialized?
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );
}

Future<void> _registerBackgroundDHTRefreshTask() async {
  await Workmanager().registerPeriodicTask(
    dhtRefreshBackgroundTaskName,
    dhtRefreshBackgroundTaskName,
    initialDelay: const Duration(seconds: 10),
    frequency: const Duration(minutes: 15),
  );
  // For updates running longer than 30s, choose this alternative for iOS
  // if (Platform.isIOS) {
  //   await Workmanager().registerProcessingTask(
  //     dhtRefreshBackgroundTaskName,
  //     dhtRefreshBackgroundTaskName,
  //     initialDelay: const Duration(seconds: 20),
  //   );
  // }
}

void main() async {
  Future<void> mainFunc() async {
    // Initialize Veilid logging
    initLoggy();

    // Make localization delegate
    final localizationDelegate = await LocalizationDelegate.create(
        fallbackLocale: 'en_US', supportedLocales: ['en_US', 'de_DE']);
    await initializeDateFormatting();

    // Helps ensure that getting the app docs directory works
    WidgetsFlutterBinding.ensureInitialized();

    // Observer for logging Bloc related things
    Bloc.observer = const CoagulateBlocObserver();

    final appStorage = await getApplicationDocumentsDirectory();

    // Persistent storage via hydrated blocs
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: appStorage);

    // Let's coagulate :)
    // Hot reloads should only restart this part, not Veilid
    runApp(LocalizedApp(localizationDelegate,
        CoagulateApp(contactsRepositoryPath: appStorage.path)));
  }

  if (kDebugMode) {
    // In debug mode, run the app without catching exceptions for debugging
    await mainFunc();
  } else {
    // Catch errors in production without killing the app
    await runZonedGuarded(mainFunc, (error, stackTrace) {
      log.error('Dart Runtime: {$error}\n{$stackTrace}');
    });
  }
}
