// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
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
        {required Location location,
        required GestureTapCallback? onTap,
        bool isDarkMode = false}) =>
    Marker(
        height: 90,
        width: 100,
        point: LatLng(location.latitude, location.longitude),
        alignment: Alignment.topCenter,
        child: GestureDetector(
            onTap: onTap,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: const EdgeInsets.only(
                      bottom: 4, left: 8, right: 8, top: 3),
                  decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.black : Colors.white)
                          .withAlpha(240),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Column(children: [
                    Text(
                      location.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    Text(
                      location.subLabel,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 10),
                    ),
                  ])),
              Icon(
                  (location.marker == MarkerType.address)
                      ? Icons.house
                      : Icons.location_pin,
                  size: 50,
                  color: Colors.deepPurple),
            ])));

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) => FlutterMap(
        options: const MapOptions(
            // TODO: Pick reasonable center without requiring all markers first; e.g. based on profile contact locations or current GPS
            initialCenter: LatLng(50.5, 30.51),
            initialZoom: 3,
            maxZoom: 15,
            minZoom: 1,
            interactionOptions: InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.doubleTapDragZoom |
                    InteractiveFlag.pinchMove)),
        children: <Widget>[
          TileLayer(
            userAgentPackageName: 'social.coagulate.app',
            urlTemplate: (mapboxToken().isEmpty)
                ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                // TODO: Add {r} along with retinaMode.isHighDensity and TileLayer.retinaMode #7
                : 'https://api.mapbox.com/styles/v1/mapbox/'
                    // For more styles, see https://docs.mapbox.com/api/maps/styles/
                    '${(MediaQuery.of(context).platformBrightness == Brightness.dark) ? 'dark-v11' : 'light-v11'}'
                    '/tiles/256/{z}/{x}/{y}?access_token=${mapboxToken()}',
          ),
          BlocProvider(
              create: (context) => MapCubit(context.read<ContactsRepository>()),
              child: BlocConsumer<MapCubit, MapState>(
                  listener: (context, state) async {},
                  builder: (context, state) {
                    final markers = state.locations
                        .map((location) => _buildMarker(
                            location: location,
                            isDarkMode:
                                MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark,
                            // TODO: Only add on tap action for other contacts, not the profile contact
                            // TODO: Style profile contact locations differently
                            onTap: (false)
                                ? () {}
                                : () {
                                    unawaited(Navigator.push(
                                        context,
                                        ContactPage.route(context
                                            .read<ContactsRepository>()
                                            .getContact(
                                                location.coagContactId))));
                                  }))
                        .toList();

                    return MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                      maxClusterRadius: 110,
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
                                  style:
                                      const TextStyle(color: Colors.white)))),
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
