// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:http/http.dart' as http;

/// Model for search result
class SearchResult {
  SearchResult({
    required this.longitude,
    required this.latitude,
    required this.placeName,
    required this.id,
  });

  factory SearchResult.fromJson(Map<String, dynamic> feature) {
    final coordinates = feature['center'] as List<dynamic>;
    return SearchResult(
      longitude: coordinates[0] as double,
      latitude: coordinates[1] as double,
      placeName: feature['place_name'] as String,
      id: feature['id'] as String,
    );
  }

  final double latitude;
  final double longitude;
  final String placeName;
  final String id;
}

/// Search function
Future<List<SearchResult>> searchLocation({
  required String query,
  required String apiKey,
  required String userAgentHeader,
  String language = 'en',
  int limit = 3,
}) async {
  final url = Uri(
    scheme: 'https',
    host: 'api.maptiler.com',
    path: '/geocoding/$query.json',
    queryParameters: {
      'language': language,
      'types': 'continental_marine,country,major_landform,region,subregion,'
          'county,joint_municipality,joint_submunicipality,municipality,'
          'municipal_district,locality,neighbourhood,place,postal_code,address,'
          'road,poi',
      'fuzzyMatch': 'true',
      'limit': limit.toString(),
      'key': apiKey,
    },
  );
  final response =
      await http.get(url, headers: {'User-Agent': userAgentHeader});

  if (response.statusCode == 200) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List;
      return features
          .map((f) => SearchResult.fromJson(f as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      // TODO: Refine error handling
      return [];
    }
  } else {
    // throw Exception('Failed to load data');
    return [];
  }
}
