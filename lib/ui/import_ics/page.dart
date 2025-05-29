// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/contact_location.dart';
import '../../data/providers/geocoding/maptiler.dart';
import '../../ics_parser.dart';
import '../map/page.dart';

class ImportIcsPage extends StatefulWidget {
  const ImportIcsPage({required this.icsData, super.key});

  final String icsData;

  @override
  _ImportIcsPageState createState() => _ImportIcsPageState();
}

class _ImportIcsPageState extends State<ImportIcsPage>
    with WidgetsBindingObserver {
  IcsEvent? _event;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialized = false;
    _event = parseIcsEvent(widget.icsData);

    unawaited(_geocodeEventLocation());
  }

  Future<void> _geocodeEventLocation() async {
    if (_event?.location != null && _event!.location!.isNotEmpty) {
      final options = await searchLocation(
          query: _event!.location!,
          apiKey: maptilerToken(),
          userAgentHeader: 'social.coagulate.app',
          limit: 1);
      if (options.isNotEmpty) {
        final location = ContactTemporaryLocation(
          longitude: options.first.longitude,
          latitude: options.first.latitude,
          name: _event!.summary,
          start: _event!.start,
          end: _event!.end,
          details: _event?.description ?? '',
          // TODO: Or keep the original calendar location string?
          address: options.first.placeName,
        );
        if (context.mounted) {
          return context.goNamed('scheduleLocation', extra: location);
        }
      }
    }

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Import ${_event?.summary ?? 'Event'}'),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (!_initialized)
                const Center(child: CircularProgressIndicator())
              else if (_event == null)
                const Text('Unable to import calendar event.',
                    textScaler: TextScaler.linear(1.2))
              else
                // TODO: Allow displaying schedule location widget with name, dates and no location to allow folks to pick a location from the map
                Text(
                    (_event!.location?.isEmpty ?? true)
                        ? 'The imported event "${_event?.summary}" has no location.'
                        : 'Unable to determine coordinates for location ${_event?.location}.',
                    textScaler: const TextScaler.linear(1.2))
            ])),
      );
}
