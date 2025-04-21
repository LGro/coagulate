// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

import '../../../data/providers/geocoding/maptiler.dart';
import '../../map/page.dart';

class LocationSearchWidget extends StatefulWidget {
  const LocationSearchWidget({this.onSelected, this.initialValue, super.key});
  final void Function(SearchResult)? onSelected;
  final String? initialValue;

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
          final options = await searchLocation(
              query: _searchingWithQuery!,
              apiKey: maptilerToken(),
              userAgentHeader: 'social.coagulate.app');

          // If another search happened after this one, throw away these options.
          // Use the previous options instead and wait for the newer request to
          // finish.
          if (_searchingWithQuery != textEditingValue.text) {
            return _lastOptions;
          }

          _lastOptions = options;
          return options;
        },
        onSelected: widget.onSelected,
        displayStringForOption: (option) => option.placeName,
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) =>
                TextFormField(
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    controller: textEditingController
                      ..text = widget.initialValue ?? '',
                    focusNode: focusNode,
                    onFieldSubmitted: (_) => onFieldSubmitted),
      );
}
