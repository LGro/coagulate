// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../locations/check_in/widget.dart';
import '../locations/cubit.dart';
import '../locations/schedule/widget.dart';
import 'cubit.dart';

// TODO: check out 'package:flutter_map_example/pages/bundled_offline_map.dart'

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

int _getWeekNumber() {
  final date = DateTime.now();
  final firstDayOfYear = DateTime(date.year, 1, 1);
  final daysOffset = firstDayOfYear.weekday - 1;
  final firstMondayOfYear = firstDayOfYear.subtract(Duration(days: daysOffset));

  final daysSinceFirstMonday = date.difference(firstMondayOfYear).inDays;
  final weekNumber = (daysSinceFirstMonday / 7).ceil() + 1;

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

String dateFormat(DateTime d, String languageCode) => [
      DateFormat.yMMMd(languageCode).format(d),
      DateFormat.Hm(languageCode).format(d),
    ].join(' ');

Future<void> showModalLocationDetails(
        BuildContext context, Location location) async =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (modalContext) => Padding(
            padding: EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
                bottom: 12 + MediaQuery.of(modalContext).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // TODO: Add information about who this is shared with
              Row(children: [
                Expanded(
                    child: Text(
                        [
                          location.label,
                          location.subLabel,
                          if (location.start != null)
                            '\nFrom: ${dateFormat(location.start!, Localizations.localeOf(context).languageCode)}',
                          if (location.end != null)
                            'Until: ${dateFormat(location.end!, Localizations.localeOf(context).languageCode)}\n',
                          location.details
                        ].join('\n'),
                        softWrap: true))
              ]),
              const SizedBox(height: 16),
              // TODO: only display if not already scheduled this (or conflicting)
              if (location.coagContactId != null) ...[
                FilledButton.tonal(
                    child: const Text('Contact details'),
                    onPressed: () async => Navigator.push(
                        context,
                        MaterialPageRoute<ContactPage>(
                            builder: (_) => ContactPage(
                                coagContactId: location.coagContactId!)))),
                const SizedBox(height: 8),
                FilledButton.tonal(
                    child: const Text('Add to my locations'),
                    onPressed: () async => Navigator.push(
                        context,
                        MaterialPageRoute<ScheduleWidget>(
                            builder: (_) => ScheduleWidget(
                                initialState: ScheduleFormState(
                                    title: location.label,
                                    details: location.details,
                                    location: PickedData(
                                        LatLong(location.latitude,
                                            location.longitude),
                                        '',
                                        {},
                                        ''),
                                    start: location.start,
                                    end: location.end))))),
              ],

              // Offer to delete app user locations
              if (location.coagContactId == null && location.locationId != null)
                FilledButton(
                  onPressed: () async => context
                      .read<MapCubit>()
                      .removeLocation(location.locationId!)
                      .then((_) =>
                          (context.mounted) ? Navigator.pop(context) : null),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.error),
                  ),
                  child: Text(
                    'Delete',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.onError),
                  ),
                ),
            ])));

Widget checkInAndScheduleButtons() => BlocProvider(
    create: (context) => LocationsCubit(context.read<ContactsRepository>()),
    child: BlocConsumer<LocationsCubit, LocationsState>(
        listener: (context, state) async {},
        builder: (context, state) => Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Row(children: [
                  const Expanded(child: SizedBox()),
                  FilledButton(
                      onPressed: () async => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (modalContext) => Padding(
                              padding: EdgeInsets.only(
                                  left: 16,
                                  top: 16,
                                  right: 16,
                                  bottom: MediaQuery.of(modalContext)
                                      .viewInsets
                                      .bottom),
                              child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [CheckInWidget()]))),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pin_drop),
                            SizedBox(width: 8),
                            Text('Check-in')
                          ])),
                  const Expanded(child: SizedBox()),
                  FilledButton(
                      onPressed: (state.circleMembersips.isEmpty)
                          ? null
                          : () async => Navigator.push(
                              context,
                              MaterialPageRoute<ScheduleWidget>(
                                  builder: (_) => const ScheduleWidget())),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(width: 8),
                            Text('Schedule')
                          ])),
                  const Expanded(child: SizedBox()),
                ])))));

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  Marker _buildMarker(BuildContext context,
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
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
                if (location.picture?.isNotEmpty ?? false)
                  CircleAvatar(
                      backgroundImage:
                          MemoryImage(Uint8List.fromList(location.picture!))),
                if (location.picture?.isEmpty ?? true)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                      // border: Border.all(
                      //     color: Theme.of(context).colorScheme.primary,
                      //     width: 4), // Blue border
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
              ])));

  @override
  Widget build(BuildContext context) => FlutterMap(
        options: const MapOptions(
            // TODO: Pick reasonable center without requiring all markers first;
            // e.g. based on profile contact locations or current GPS
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
                        .map((location) => _buildMarker(context,
                            location: location,
                            isDarkMode:
                                MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark,
                            // TODO: Style profile contact locations differently
                            onTap: (location.coagContactId == null &&
                                    location.marker == MarkerType.address)
                                ? null
                                : (location.marker == MarkerType.temporary)
                                    ? () async => showModalLocationDetails(
                                        context, location)
                                    : () {
                                        // Provoke a null result in case no id
                                        final contact = context
                                            .read<ContactsRepository>()
                                            .getContact(
                                                location.coagContactId ?? '-');
                                        if (contact == null) {
                                          // TODO: display error?
                                          return;
                                        }
                                        unawaited(Navigator.push(context,
                                            ContactPage.route(contact)));
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
                              color: Theme.of(context).colorScheme.primary),
                          child: Center(
                              child: Text(markers.length.toString(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)))),
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
              ]),
          // Check-in and schedule buttons
          checkInAndScheduleButtons(),
        ],
      );
}
