// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubit/contacts_cubit.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../../data/models/coag_contact.dart';
import 'cubit.dart';

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

int _getWeekNumber() {
  DateTime date = DateTime.now();
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  int daysOffset = firstDayOfYear.weekday - 1;
  DateTime firstMondayOfYear =
      firstDayOfYear.subtract(Duration(days: daysOffset));

  int daysSinceFirstMonday = date.difference(firstMondayOfYear).inDays;
  int weekNumber = (daysSinceFirstMonday / 7).ceil() + 1;

  return weekNumber;
}

class _SliderExampleState extends State<SliderExample> {
  // TODO: Manage state in the parent scope to allow state dependent filtering of markers
  double _currentSliderValue = _getWeekNumber().roundToDouble();

  @override
  Widget build(BuildContext context) => Slider(
        value: _currentSliderValue,
        min: 1,
        max: 52,
        divisions: 51,
        // TODO: Show Month as well
        label: _currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentSliderValue = value;
          });
        },
      );
}

String mapboxToken() =>
    const String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN');

Marker _buildMarker(
        {required Location location, required GestureTapCallback? onTap}) =>
    Marker(
        height: 60,
        width: 100,
        point: LatLng(location.latitude, location.longitude),
        alignment: Alignment.topCenter,
        child: GestureDetector(
            onTap: onTap,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                location.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              // TODO: Display not just the first address but all of them
              // TODO: Display label of the address
              Text(
                location.subLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.location_pin, size: 26, color: Colors.deepPurple)
            ])));

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) => FlutterMap(
        options: const MapOptions(
          // TODO: Pick reasonable center without requiring all markers first
          initialCenter: LatLng(50.5, 30.51),
          initialZoom: 3,
          maxZoom: 15,
          minZoom: 1,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: (mapboxToken().isEmpty)
                ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                // TODO: Add {r} along with retinaMode.isHighDensity and TileLayer.retinaMode #7
                : 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}?access_token=${mapboxToken()}',
          ),
          BlocProvider(
              create: (context) => MapCubit(context.read<ContactsRepository>()),
              child: BlocConsumer<MapCubit, MapState>(
                  listener: (context, state) async {
                print('map bloc provider listener');
              }, builder: (context, state) {
                print('map bloc provider building');
                final markers = state.locations
                    .map((location) => _buildMarker(
                        location: location,
                        onTap: () {
                          // unawaited(Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         // FIXME: That's the wrong id, it expects a system contact id
                          //         builder: (_) => ContactPage(
                          //             contactId: location.coagContactId)
                          //             )));
                        }))
                    .toList();

                return MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                  maxClusterRadius: 100,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 15,
                  markers: markers,
                  builder: (context, markers) => DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepPurple),
                      child: Center(
                          child: Text(markers.length.toString(),
                              style: const TextStyle(color: Colors.white)))),
                ));
              })),
          // TODO: Consider replacing it with a start and end date selection
          // const Align(
          //     alignment: Alignment.bottomLeft,
          //     child: FittedBox(child: SliderExample())),
          RichAttributionWidget(
              showFlutterMapAttribution: false,
              attributions: [
                if (mapboxToken().isEmpty)
                  TextSourceAttribution(
                    'OpenStreetMap',
                    onTap: () async => launchUrl(
                        Uri.parse('https://www.openstreetmap.org/copyright')),
                  )
                else
                  TextSourceAttribution(
                    'Mapbox',
                    onTap: () async => launchUrl(
                        Uri.parse('https://www.mapbox.com/about/maps/')),
                  )
              ])
        ],
      );
}
