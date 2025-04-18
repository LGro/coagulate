// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/contact_location.dart';
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

Future<void> showModalAddressLocationDetails(
  BuildContext context, {
  required String contactName,
  required ContactAddressLocation location,
}) async =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.90,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
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
                          contactName,
                          'Label: ${location.name}',
                          if (location.address != null)
                            'Address: ${location.address}'
                        ].join('\n\n'),
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
              ],
            ]),
          ),
        ),
      ),
    );

Future<void> showModalTemporaryLocationDetails(
  BuildContext context, {
  required String contactName,
  required ContactTemporaryLocation location,
  required String locationId,
  bool showEditAndDelete = false,
  Map<String, String> circles = const {},
  Map<String, List<String>> circleMemberships = const {},
}) async =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.90,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
                bottom: 12 + MediaQuery.of(modalContext).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                  child: Text(
                      [
                        contactName,
                        location.name,
                        '',
                        if (location.address != null) ...[
                          'Address: ${location.address}',
                          ''
                        ],
                        'From: ${dateFormat(location.start, Localizations.localeOf(context).languageCode)}',
                        'Until: ${dateFormat(location.end, Localizations.localeOf(context).languageCode)}',
                        '',
                        if (location.details.isNotEmpty) ...[
                          'Details: ${location.details}',
                          ''
                        ],
                        if (location.circles.isNotEmpty &&
                            circles.isNotEmpty) ...[
                          'Shared with {N} contacts via circles: {C}'
                              .replaceFirst(
                                  '{N}',
                                  circleMemberships.values
                                      .where((cIds) => cIds
                                          .asSet()
                                          .intersectsWith(
                                              location.circles.asSet()))
                                      .length
                                      .toString())
                              .replaceFirst(
                                  '{C}',
                                  location.circles
                                      .map((cId) => circles[cId])
                                      .whereType<String>()
                                      .join(', '))
                        ],
                      ].join('\n'),
                      softWrap: true),
                ),
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
                          builder: (_) =>
                              ScheduleWidget(locationId: locationId))),
                ),
              ],

              if (showEditAndDelete)
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton(
                        onPressed: () async => context
                            .read<MapCubit>()
                            .removeLocation(locationId)
                            .then((_) => (context.mounted)
                                ? Navigator.pop(context)
                                : null),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.error),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onError),
                        ),
                      ),
                      FilledButton(
                        onPressed: () async => Navigator.push(
                            context,
                            MaterialPageRoute<ScheduleWidget>(
                                builder: (_) =>
                                    ScheduleWidget(locationId: locationId))),
                        child: const Text('Edit'),
                      ),
                    ]),
            ]),
          ),
        ),
      ),
    );

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
                          builder: (modalContext) => DraggableScrollableSheet(
                              expand: false,
                              maxChildSize: 0.90,
                              builder: (_, scrollController) =>
                                  SingleChildScrollView(
                                      controller: scrollController,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 16,
                                              top: 16,
                                              right: 16,
                                              bottom:
                                                  MediaQuery.of(modalContext)
                                                      .viewInsets
                                                      .bottom),
                                          child: const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [CheckInWidget()]))))),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pin_drop),
                            SizedBox(width: 8),
                            Text('Check-in'),
                          ])),
                  const Expanded(child: SizedBox()),
                  FilledButton(
                      onPressed: () async => Navigator.push(
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

  Marker _buildMarker(
    BuildContext context, {
    required double longitude,
    required double latitude,
    required String label,
    required String subLabel,
    required MarkerType type,
    required GestureTapCallback? onTap,
    List<int>? picture,
  }) =>
      Marker(
          height: 90,
          width: 100,
          point: LatLng(latitude, longitude),
          alignment: Alignment.topCenter,
          child: GestureDetector(
              onTap: onTap,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    padding: const EdgeInsets.only(
                        bottom: 4, left: 8, right: 8, top: 3),
                    decoration: BoxDecoration(
                        color: ((MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                ? Colors.black
                                : Colors.white)
                            .withAlpha(240),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: Column(children: [
                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      Text(
                        subLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 10),
                      ),
                    ])),
                Stack(
                    clipBehavior: Clip
                        .none, // Allows the icon to overflow outside the circle
                    children: [
                      if (picture?.isNotEmpty ?? false)
                        CircleAvatar(
                            backgroundImage:
                                MemoryImage(Uint8List.fromList(picture!)))
                      else
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary,
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                width: 4), // Blue border
                          ),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      // Icon overlay
                      Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(2),
                            // TODO: Handle MarkerType.checkedIn
                            child: Icon(
                              (type == MarkerType.address)
                                  ? Icons.home_filled
                                  : Icons.schedule,
                              size: 16,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ))
                    ]),
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
                    final markers = <Marker>[
                      // Profile temporary locations
                      ...(state.profileInfo?.temporaryLocations.entries ?? [])
                          .map(
                        (l) => _buildMarker(
                          context,
                          longitude: l.value.longitude,
                          latitude: l.value.latitude,
                          label: 'Me',
                          subLabel: l.value.name,
                          type: (l.value.checkedIn)
                              ? MarkerType.checkedIn
                              : MarkerType.temporary,
                          picture:
                              state.profileInfo?.pictures.values.firstOrNull,
                          onTap: () async => showModalTemporaryLocationDetails(
                            context,
                            contactName: 'Me',
                            location: l.value,
                            locationId: l.key,
                            showEditAndDelete: true,
                            circles: state.circles,
                            circleMemberships: state.circleMemberships,
                          ),
                        ),
                      ),
                      // Contacts temporary locations
                      ...state.contacts
                          .map(
                            (c) => c.temporaryLocations.entries.map(
                              (l) => _buildMarker(
                                context,
                                longitude: l.value.longitude,
                                latitude: l.value.latitude,
                                label: c.name,
                                subLabel: l.value.name,
                                type: MarkerType.temporary,
                                picture: c.details?.picture,
                                onTap: () async =>
                                    showModalTemporaryLocationDetails(
                                  context,
                                  contactName: c.name,
                                  location: l.value
                                      .copyWith(coagContactId: c.coagContactId),
                                  locationId: l.key,
                                ),
                              ),
                            ),
                          )
                          .expand((l) => l),
                      // Profile address locations
                      ...(state.profileInfo?.addressLocations.values ?? []).map(
                        (l) => _buildMarker(
                          context,
                          longitude: l.longitude,
                          latitude: l.latitude,
                          label: 'Me',
                          subLabel: l.name,
                          type: MarkerType.address,
                          picture:
                              state.profileInfo?.pictures.values.firstOrNull,
                          onTap: () async => showModalAddressLocationDetails(
                              context,
                              contactName: 'Me',
                              location: l),
                        ),
                      ),
                      // Contacts address locations
                      ...state.contacts
                          .map(
                            (c) => c.addressLocations.values.map(
                              (l) => _buildMarker(
                                context,
                                longitude: l.longitude,
                                latitude: l.latitude,
                                label: c.name,
                                subLabel: l.name,
                                type: MarkerType.address,
                                picture: c.details?.picture,
                                onTap: () async =>
                                    showModalAddressLocationDetails(context,
                                        contactName: c.name, location: l),
                              ),
                            ),
                          )
                          .expand((l) => l),
                    ];

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
