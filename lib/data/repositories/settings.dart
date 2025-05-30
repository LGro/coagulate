// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

// NOTE: We rely on the order of the items with storing preferences
enum MapProvider { osm, maptiler, custom }

String maptilerToken() =>
    const String.fromEnvironment('COAGULATE_MAPTILER_TOKEN');

class SettingsRepository {
  SettingsRepository(
      {required bool darkMode, required double devicePixelRatio}) {
    _darkMode = darkMode;
    _devicePixelRatio = devicePixelRatio;
    unawaited(_init());
  }

  String _bootstrapServer = 'bootstrap-v1.veilid.net';
  bool _darkMode = false;
  double _devicePixelRatio = 1;
  MapProvider _mapProvider = MapProvider.maptiler;
  String _customMapProviderUrl = '';

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();

    _bootstrapServer = sp.getString('bootstrapServer') ?? _bootstrapServer;
    _darkMode = sp.getBool('darkMode') ?? _darkMode;
    _mapProvider =
        MapProvider.values[sp.getInt('mapProvider') ?? _mapProvider.index];
    _customMapProviderUrl =
        sp.getString('customMapProviderUrl') ?? _customMapProviderUrl;
  }

  Future<void> setBootstrapServer(String value) async {
    _bootstrapServer = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('bootstrapServer', value);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('darkMode', value);
  }

  Future<void> setMapProvider(MapProvider value) async {
    _mapProvider = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('mapProvider', value.index);
  }

  Future<void> setCustomMapProviderUrl(String value) async {
    _customMapProviderUrl = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('customMapProviderUrl', value);
  }

  MapProvider get mapProvider => _mapProvider;
  bool get darkMode => _darkMode;

  String get mapUrl {
    switch (_mapProvider) {
      case MapProvider.osm:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapProvider.maptiler:
        return [
          'https://api.maptiler.com/maps/dataviz-',
          if (_darkMode) 'dark' else 'light',
          '/{z}/{x}/{y}',
          if (_devicePixelRatio >= 1) '@2x' else '',
          '.png?key=',
          maptilerToken(),
        ].join();
      case MapProvider.custom:
        return _customMapProviderUrl;
    }
  }
}
