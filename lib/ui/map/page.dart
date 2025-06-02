// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../../data/repositories/settings.dart';
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

LatLng? initialLocation(
  Iterable<ContactAddressLocation> profileAddressLocations,
  Iterable<ContactTemporaryLocation> profileTemporaryLocations,
  Iterable<ContactAddressLocation> contactAddressLocations,
  Iterable<ContactTemporaryLocation> contactTemporaryLocations,
) {
  if (profileAddressLocations.isNotEmpty) {
    return LatLng(profileAddressLocations.map((l) => l.latitude).average,
        profileAddressLocations.map((l) => l.longitude).average);
  }

  if (profileTemporaryLocations.isNotEmpty) {
    return LatLng(profileTemporaryLocations.map((l) => l.latitude).average,
        profileTemporaryLocations.map((l) => l.longitude).average);
  }

  if (contactAddressLocations.isNotEmpty ||
      contactTemporaryLocations.isNotEmpty) {
    return LatLng(
      (contactAddressLocations.map((l) => l.latitude).toList()
            ..addAll(contactTemporaryLocations.map((l) => l.latitude)))
          .average,
      (contactAddressLocations.map((l) => l.longitude).toList()
            ..addAll(contactTemporaryLocations.map((l) => l.longitude)))
          .average,
    );
  }

  return null;
}

String dateFormat(DateTime d, String languageCode) => [
      DateFormat.yMMMd(languageCode).format(d),
      DateFormat.Hm(languageCode).format(d),
    ].join(' ');

Future<void> showModalAddressLocationDetails(
  BuildContext context, {
  required String contactName,
  required String label,
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
                left: 24,
                top: 16,
                right: 24,
                bottom: 12 + MediaQuery.of(modalContext).viewInsets.bottom),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$contactName @ $label',
                      softWrap: true,
                      textScaler: const TextScaler.linear(1.4),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 16),
                  if (location.address != null)
                    Row(children: [
                      const Icon(Icons.pin_drop),
                      const SizedBox(width: 12),
                      Expanded(child: Text(location.address!, softWrap: true)),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                          onPressed: () async => SharePlus.instance
                              .share(ShareParams(text: location.address)),
                          icon: const Icon(Icons.copy)),
                    ]),
                  // TODO: Add information about who this is shared with
                  const SizedBox(height: 16),
                  if (location.coagContactId != null) ...[
                    Center(
                        child: FilledButton.tonal(
                            child: const Text('Contact details'),
                            onPressed: () async => Navigator.push(
                                context,
                                MaterialPageRoute<ContactPage>(
                                    builder: (_) => ContactPage(
                                        coagContactId:
                                            location.coagContactId!))))),
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
                left: 24,
                top: 16,
                right: 24,
                bottom: 12 + MediaQuery.of(modalContext).viewInsets.bottom),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$contactName @ ${location.name}',
                      softWrap: true,
                      textScaler: const TextScaler.linear(1.4),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 16),
                  if (location.address != null)
                    Row(children: [
                      const Icon(Icons.pin_drop),
                      const SizedBox(width: 12),
                      Expanded(child: Text(location.address!, softWrap: true)),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                          onPressed: () async => SharePlus.instance
                              .share(ShareParams(text: location.address)),
                          icon: const Icon(Icons.copy)),
                    ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.calendar_month),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'From: ${dateFormat(location.start, Localizations.localeOf(context).languageCode)}\n'
                            'Until: ${dateFormat(location.end, Localizations.localeOf(context).languageCode)}',
                            softWrap: true)),
                  ]),
                  const SizedBox(height: 16),
                  if (location.details.isNotEmpty) ...[
                    Row(children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 12),
                      Expanded(child: Text(location.details, softWrap: true))
                    ]),
                    const SizedBox(height: 16),
                  ],
                  if (location.circles.isNotEmpty && circles.isNotEmpty)
                    Row(children: [
                      const Icon(Icons.bubble_chart_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
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
                                          .join(', ')),
                              softWrap: true))
                    ]),
                  const SizedBox(height: 24),
                  // TODO: only display if not already scheduled this (or conflicting)
                  if (location.coagContactId != null) ...[
                    Center(
                        child: FilledButton.tonal(
                            child: const Text('Contact details'),
                            onPressed: () async => Navigator.push(
                                context,
                                MaterialPageRoute<ContactPage>(
                                    builder: (_) => ContactPage(
                                        coagContactId:
                                            location.coagContactId!))))),
                    const SizedBox(height: 8),
                    Center(
                        child: FilledButton.tonal(
                            onPressed: () async => Navigator.push(
                                context,
                                MaterialPageRoute<ScheduleWidget>(
                                    builder: (_) => ScheduleWidget(
                                        locationId: locationId,
                                        location: location))),
                            child: const Text('Add to my locations'))),
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
                                    builder: (_) => ScheduleWidget(
                                        locationId: locationId,
                                        location: location))),
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
    required bool darkMode,
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
                        color: (darkMode ? Colors.black : Colors.white)
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
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => MapCubit(context.read<ContactsRepository>(),
          context.read<SettingsRepository>()),
      child: BlocConsumer<MapCubit, MapState>(
          listener: (context, state) async {},
          builder: (context, state) => (state.cachePath == null ||
                  state.profileInfo == null)
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  options: MapOptions(
                      // TODO: Pick reasonable center without requiring all markers first;
                      // e.g. based on profile contact locations or current GPS
                      initialCenter: initialLocation(
                              state.profileInfo?.addressLocations.values ?? [],
                              state.profileInfo?.temporaryLocations.values ??
                                  [],
                              state.contacts
                                  .map((c) => c.addressLocations.values)
                                  .expand((l) => l),
                              state.contacts
                                  .map((c) => c.temporaryLocations.values)
                                  .expand((l) => l)) ??
                          const LatLng(47, 8),
                      initialZoom: 4,
                      maxZoom: 15,
                      minZoom: 1,
                      interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.pinchZoom |
                              InteractiveFlag.drag |
                              InteractiveFlag.doubleTapZoom |
                              InteractiveFlag.doubleTapDragZoom |
                              InteractiveFlag.pinchMove)),
                  children: <Widget>[
                    TileLayer(
                      userAgentPackageName: 'social.coagulate.app',
                      urlTemplate: context.read<SettingsRepository>().mapUrl,
                      tileProvider: CachedTileProvider(
                        maxStale: const Duration(days: 30),
                        store: FileCacheStore(state.cachePath!),
                      ),
                    ),
                    MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                      maxClusterRadius: 110,
                      size: const Size(40, 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(50),
                      maxZoom: 15,
                      markers: <Marker>[
                        // Profile temporary locations
                        ...filterTemporaryLocations(
                                state.profileInfo?.temporaryLocations ?? {})
                            .entries
                            .map(
                              (l) => _buildMarker(
                                context,
                                longitude: l.value.longitude,
                                latitude: l.value.latitude,
                                label: 'Me',
                                subLabel: l.value.name,
                                darkMode:
                                    context.read<SettingsRepository>().darkMode,
                                type: (l.value.checkedIn)
                                    ? MarkerType.checkedIn
                                    : MarkerType.temporary,
                                picture: state
                                    .profileInfo?.pictures.values.firstOrNull,
                                onTap: () async =>
                                    showModalTemporaryLocationDetails(
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
                              (c) =>
                                  filterTemporaryLocations(c.temporaryLocations)
                                      .entries
                                      .map(
                                        (l) => _buildMarker(
                                          context,
                                          longitude: l.value.longitude,
                                          latitude: l.value.latitude,
                                          label: c.name,
                                          subLabel: l.value.name,
                                          type: MarkerType.temporary,
                                          darkMode: context
                                              .read<SettingsRepository>()
                                              .darkMode,
                                          picture: c.details?.picture,
                                          onTap: () async =>
                                              showModalTemporaryLocationDetails(
                                            context,
                                            contactName: c.name,
                                            location: l.value.copyWith(
                                                coagContactId: c.coagContactId),
                                            locationId: l.key,
                                          ),
                                        ),
                                      ),
                            )
                            .expand((l) => l),
                        // Profile address locations
                        ...(state.profileInfo?.addressLocations ?? {})
                            .map(
                              (label, location) => MapEntry(
                                  label,
                                  _buildMarker(
                                    context,
                                    longitude: location.longitude,
                                    latitude: location.latitude,
                                    label: 'Me',
                                    subLabel: label,
                                    type: MarkerType.address,
                                    darkMode: context
                                        .read<SettingsRepository>()
                                        .darkMode,
                                    picture: state.profileInfo?.pictures.values
                                        .firstOrNull,
                                    onTap: () async =>
                                        showModalAddressLocationDetails(context,
                                            contactName: 'Me',
                                            label: label,
                                            location: location),
                                  )),
                            )
                            .values,
                        // Contacts address locations
                        ...state.contacts
                            .map((c) => c.addressLocations
                                .map((label, location) => MapEntry(
                                      label,
                                      _buildMarker(
                                        context,
                                        longitude: location.longitude,
                                        latitude: location.latitude,
                                        label: c.name,
                                        subLabel: label,
                                        type: MarkerType.address,
                                        darkMode: context
                                            .read<SettingsRepository>()
                                            .darkMode,
                                        picture: c.details?.picture,
                                        onTap: () async =>
                                            showModalAddressLocationDetails(
                                                context,
                                                label: label,
                                                contactName: c.name,
                                                location: location),
                                      ),
                                    ))
                                .values)
                            .expand((l) => l),
                      ],
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
                    )),
                    // TODO: Consider replacing it with a start and end date selection
                    // const Align(
                    //     alignment: Alignment.bottomLeft,
                    //     child: FittedBox(child: SliderExample())),
                    RichAttributionWidget(
                        showFlutterMapAttribution: false,
                        attributions: [
                          if (context
                              .read<SettingsRepository>()
                              .mapUrl
                              .contains('maptiler'))
                            TextSourceAttribution(
                              'MapTiler',
                              onTap: () async =>
                                  launchUrl(Uri.parse('https://maptiler.com/')),
                            ),
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                            onTap: () async => launchUrl(
                                Uri.parse('https://openstreetmap.org/')),
                          )
                        ]),
                    // Check-in and schedule buttons
                    checkInAndScheduleButtons(),
                  ],
                )));
}
