// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

import '../../../data/providers/geocoding/photon.dart';

class LocationSearchWidget extends StatefulWidget {
  const LocationSearchWidget({super.key});

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  // The query currently being searched for. If null, no request is pending.
  String? _searchingWithQuery;

  // The most recent options received from the API.
  late Iterable<SearchResult> _lastOptions = [];

  @override
  Widget build(BuildContext context) => Autocomplete<SearchResult>(
        optionsBuilder: (textEditingValue) async {
          _searchingWithQuery = textEditingValue.text;
          final options = await searchLocation(_searchingWithQuery!);

          // If another search happened after this one, throw away these options.
          // Use the previous options instead and wait for the newer request to
          // finish.
          if (_searchingWithQuery != textEditingValue.text) {
            return _lastOptions;
          }

          _lastOptions = options;
          return options;
        },
        onSelected: (selection) {
          debugPrint('You just selected $selection');
        },
        displayStringForOption: (option) => <String>[
          option.street,
          option.houseNumber,
          option.city,
          option.country
        ].where((v) => v.isNotEmpty).join(', '),
      );
}
