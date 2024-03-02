// Copyright 2024 Lukas Grossberger
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'bloc_observer.dart';
import 'tools/loggy.dart';
import 'veilid_init.dart';

void main() async {
  // Initialize Veilid logging
  initLoggy();

  // Startup Veilid network connectivity in the background
  unawaited(initializeVeilid());

  // Helps ensure that getting the app docs directory works
  WidgetsFlutterBinding.ensureInitialized();

  // Set MapBox api token
  MapboxOptions.setAccessToken(
      const String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN'));

  // Observer for logging Bloc related things
  Bloc.observer = const CoagulateBlocObserver();

  // Persistent storage via hydrated blocs
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());

  // Let's coagulate :)
  runApp(CoagulateApp());
}
