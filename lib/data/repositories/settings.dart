// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import '../providers/persistent_storage.dart';

enum MapProvider {
  osm,
  mapbox,
  // apple,
  // google,
}

class SettingsRepository {
  SettingsRepository(this._persistentStoragePath) {
    _init();
  }

  final String _persistentStoragePath;
  late final HivePersistentStorage _persistentStorage =
      HivePersistentStorage(_persistentStoragePath);

  String bootstrapServer = 'bootstrap.veilid.net';

  // TODO: Expose
  final bool darkmode = false;
  final MapProvider mapProvider = MapProvider.mapbox;

  // TODO: Save and load from persistent storage

  void _init() {}
}
