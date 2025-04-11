// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:http/http.dart' as http;

/// Model for search result
class SearchResult {
  SearchResult({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.city,
    required this.street,
    required this.houseNumber,
    required this.postcode,
    required this.state,
    required this.district,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>;
    final coords = json['geometry']['coordinates'] as List<dynamic>;
    return SearchResult(
      latitude: coords[1] as double,
      longitude: coords[0] as double,
      country: props['country'] as String? ?? '',
      city: props['city'] as String? ?? '',
      street: props['street'] as String? ?? '',
      houseNumber: props['housenumber'] as String? ?? '',
      postcode: props['postcode'] as String? ?? '',
      state: props['state'] as String? ?? '',
      district: props['district'] as String? ?? '',
    );
  }

  final double latitude;
  final double longitude;
  final String country;
  final String city;
  final String street;
  final String houseNumber;
  final String postcode;
  final String state;
  final String district;
}

/// Search function
Future<List<SearchResult>> searchLocation(String query) async {
  final url = Uri(
      scheme: 'https',
      host: 'photon.komoot.io',
      path: '/api',
      queryParameters: {'q': query});
  final response = await http
      .get(url, headers: {'User-Agent': 'social.coagulate.app / testing'});

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final features = data['features'] as List;
    return features
        .map((f) => SearchResult.fromJson(f as Map<String, dynamic>))
        .toList();
  } else {
    // throw Exception('Failed to load data');
    return [];
  }
}
