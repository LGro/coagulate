// Copyright 2024 Lukas Grossberger
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'profile_contact_bloc_observer.dart';
import 'veilid_init.dart';

void main() async {
  unawaited(initializeVeilid());

  // Helps ensure that getting the app docs directory works
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const ProfilecontactBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  runApp(CoagulateApp());
}
