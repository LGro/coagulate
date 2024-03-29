// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc_observer.dart';
import 'data/repositories/contacts.dart';
import 'ui/screens/app.dart';
import 'tools/loggy.dart';
import 'veilid_init.dart';

void main() async {
  // Catch errors
  await runZonedGuarded(() async {
    // Initialize Veilid logging
    initLoggy();

    // Start up Veilid and Veilid processor in the background
    unawaited(initializeVeilidChat());

    // // Make localization delegate
    // final localizationDelegate = await LocalizationDelegate.create(
    //     fallbackLocale: 'en_US', supportedLocales: ['en_US']);

    // Helps ensure that getting the app docs directory works
    WidgetsFlutterBinding.ensureInitialized();

    // Observer for logging Bloc related things
    Bloc.observer = const CoagulateBlocObserver();

    final appStorage = await getApplicationDocumentsDirectory();

    // Persistent storage via hydrated blocs
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: appStorage);

    // Let's coagulate :)
    // TODO: Add LocalizedApp wrapper using localizationDelegate
    runApp(
        CoagulateApp(contactsRepository: ContactsRepository(appStorage.path)));
  }, (error, stackTrace) {
    log.error('Dart Runtime: {$error}\n{$stackTrace}');
  });
}
