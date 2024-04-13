// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc_observer.dart';
import 'data/repositories/contacts.dart';
import 'tools/loggy.dart';
import 'ui/app.dart';

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
        CoagulateApp(contactsRepository: ContactsRepository(appStorage.path))));
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
