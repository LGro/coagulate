// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:formz/formz.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/contact_location.dart';
import '../../../data/providers/geocoding/maptiler.dart';
import '../../../data/repositories/contacts.dart';
import '../../map/page.dart';
import '../../widgets/location_search/widget.dart';
import 'cubit.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.initialLocation, this.onSelected});

  @override
  State<StatefulWidget> createState() => MapWidgetState();

  final SearchResult? initialLocation;
  final void Function(SearchResult)? onSelected;
}

class MapWidgetState extends State<MapWidget> {
  final _mapController = MapController();
  SearchResult? _selectedLocation;
  String? _cachePath;

  @override
  void initState() {
    _selectedLocation = widget.initialLocation;
    super.initState();
    unawaited(_initializeCachePath());
  }

  Future<void> _initializeCachePath() async {
    final cachePath = await getTemporaryDirectory().then((td) => td.path);
    setState(() {
      _cachePath = cachePath;
    });
  }

  @override
  Widget build(BuildContext context) => (_cachePath == null)
      ? const Center(child: CircularProgressIndicator())
      : FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            // TODO: Pick reasonable center without requiring all markers first;
            // e.g. based on profile contact locations or current GPS
            initialCenter: (_selectedLocation == null)
                ? const LatLng(48.8575, 2.3514)
                : LatLng(
                    _selectedLocation!.latitude, _selectedLocation!.longitude),
            initialZoom: 3,
            maxZoom: 15,
            minZoom: 1,
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.doubleTapDragZoom |
                    InteractiveFlag.pinchMove),
            // onPositionChanged: (camera, hasGesture) => camera.center,
          ),
          children: <Widget>[
            TileLayer(
              userAgentPackageName: 'social.coagulate.app',
              urlTemplate: mapUrl(context),
              tileProvider: CachedTileProvider(
                maxStale: const Duration(days: 30),
                store: FileCacheStore(_cachePath!),
              ),
            ),
            // Copyright notice
            RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    'MapTiler',
                    onTap: () async =>
                        launchUrl(Uri.parse('https://maptiler.com/')),
                  ),
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () async =>
                        launchUrl(Uri.parse('https://openstreetmap.org/')),
                  )
                ]),
            // Selected location
            MarkerLayer(markers: [
              if (_selectedLocation != null)
                Marker(
                    point: LatLng(_selectedLocation!.latitude,
                        _selectedLocation!.longitude),
                    child: const Icon(Icons.location_on))
            ]),
            // Search bar
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: LocationSearchWidget(
                        initialValue: _selectedLocation?.placeName,
                        onSelected: (l) {
                          setState(() {
                            _selectedLocation = l;
                          });
                          _mapController.move(
                              LatLng(l.latitude, l.longitude), 13);
                          if (widget.onSelected != null) {
                            widget.onSelected!(l);
                          }
                        }))),
          ],
        );
}

class MyForm extends StatefulWidget {
  const MyForm(
      {required this.callback,
      super.key,
      this.circles = const {},
      this.circleMemberships = const {},
      this.initialState});

  final ScheduleFormState? initialState;

  final Future<void> Function({
    required String name,
    required String details,
    required String address,
    required DateTime start,
    required DateTime end,
    required LatLng coordinates,
    required List<String> circles,
  }) callback;

  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  @override
  State<MyForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<MyForm> {
  final _key = GlobalKey<FormState>();
  late ScheduleFormState _state;
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ??
        ScheduleFormState(
            circles: widget.circles
                .map((id, label) => MapEntry(id, (
                      id,
                      label,
                      false,
                      widget.circleMemberships.values
                          .where((circles) => circles.contains(id))
                          .length
                    )))
                .values
                .toList());
    _titleController = TextEditingController(text: _state.title)
      ..addListener(_onTitleChanged);
    _detailsController = TextEditingController(text: _state.details)
      ..addListener(_onDetailsChanged);
  }

  void _onTitleChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(title: _titleController.text);
    });
  }

  void _onDetailsChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(details: _detailsController.text);
    });
  }

  void _onStartTimeChanged(TimeOfDay value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(
          start: DateTime(_state.start!.year, _state.start!.month,
              _state.start!.day, value.hour, value.minute));
    });
  }

  void _onEndTimeChanged(TimeOfDay value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(
          end: DateTime(_state.end!.year, _state.end!.month, _state.end!.day,
              value.hour, value.minute));
    });
  }

  void _onLocationChanged(SearchResult value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(location: value);
    });
  }

  void _onDateRangeChanged(DateTimeRange value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _state = _state.copyWith(
          start: DateTime(
            value.start.year,
            value.start.month,
            value.start.day,
            _state.start?.hour ?? 0,
            _state.start?.minute ?? 0,
          ),
          end: DateTime(
            value.end.year,
            value.end.month,
            value.end.day,
            _state.end?.hour ?? 0,
            _state.end?.minute ?? 0,
          ));
    });
  }

  void _updateCircleSelection(int i, bool selected) {
    if (!mounted) {
      return;
    }
    final circles = List<(String, String, bool, int)>.from(_state.circles);
    circles[i] = (circles[i].$1, circles[i].$2, selected, circles[i].$4);
    setState(() {
      _state = _state.copyWith(circles: circles);
    });
  }

  Future<void> _onSubmit() async {
    if (!_key.currentState!.validate() || !mounted) {
      return;
    }

    setState(() {
      _state = _state.copyWith(status: FormzSubmissionStatus.inProgress);
    });

    try {
      await widget.callback(
          name: _state.title,
          details: _state.details,
          address: _state.location!.placeName,
          circles: _state.circles.where((c) => c.$3).map((c) => c.$1).toList(),
          start: _state.start!,
          end: _state.end!,
          coordinates:
              LatLng(_state.location!.latitude, _state.location!.longitude));
      _state = _state.copyWith(status: FormzSubmissionStatus.success);
      Navigator.pop(context);
    } catch (e) {
      _state = _state.copyWith(status: FormzSubmissionStatus.failure);
    }

    // TODO: Handle errors?

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      child: Form(
          key: _key,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextFormField(
                  key: const Key('myForm_titleInput'),
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperMaxLines: 2,
                    labelText: 'Title',
                    errorMaxLines: 2,
                  ),
                  textInputAction: TextInputAction.done,
                )),
            const SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextFormField(
                  key: const Key('myForm_detailsInput'),
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperMaxLines: 2,
                    labelText: 'Details',
                    errorMaxLines: 2,
                  ),
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                )),
            const SizedBox(height: 16),
            const Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(children: [
                  Text('and share with circles',
                      textScaler: TextScaler.linear(1.2))
                ])),
            Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _state.circles
                    .asMap()
                    .map((i, c) => MapEntry(
                        i,
                        GestureDetector(
                            onTap: () => _updateCircleSelection(i, !c.$3),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                    value: c.$3,
                                    onChanged: (value) => (value == null)
                                        ? null
                                        : _updateCircleSelection(i, value)),
                                Text('${c.$2} (${c.$4})'),
                                const SizedBox(width: 4),
                              ],
                            ))))
                    .values
                    .toList()),
            const SizedBox(height: 16),
            Row(children: [
              TextButton(
                  child: Text((_state.start == null)
                      ? 'Pick Start Date'
                      : DateFormat.yMd().format(_state.start!)),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 356 * 2)),
                        initialDateRange: DateTimeRange(
                            start: _state.start ?? DateTime.now(),
                            end: _state.end ??
                                _state.start ??
                                DateTime.now().add(const Duration(days: 1))));
                    if (range != null) {
                      _onDateRangeChanged(range);
                    }
                  }),
              if (_state.start != null)
                TextButton(
                    child: Text(DateFormat.Hm().format(_state.start!)),
                    onPressed: () async => showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: _state.start!.hour,
                            minute: _state.start!.minute),
                        builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!)).then(
                        (t) => (t == null) ? null : _onStartTimeChanged(t))),
            ]),
            Row(children: [
              TextButton(
                  child: Text((_state.end == null)
                      ? 'Pick End Date'
                      : DateFormat.yMd().format(_state.end!)),
                  onPressed: () async => showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 356 * 2)),
                          initialDateRange: DateTimeRange(
                              start: _state.start ?? DateTime.now(),
                              end: _state.end ??
                                  _state.start ??
                                  DateTime.now().add(const Duration(days: 1))))
                      .then((range) =>
                          (range == null) ? null : _onDateRangeChanged)),
              if (_state.end != null)
                TextButton(
                    child: Text(DateFormat.Hm().format(_state.end!)),
                    onPressed: () async => showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: _state.end!.hour, minute: _state.end!.minute),
                        builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!)).then(
                        (t) => (t == null) ? null : _onEndTimeChanged(t))),
            ]),
            const SizedBox(height: 16),
            SizedBox(
                height: 380,
                child: MapWidget(
                  initialLocation: _state.location,
                  onSelected: _onLocationChanged,
                )),
            const SizedBox(height: 16),
            if (_state.status.isInProgress)
              const CircularProgressIndicator()
            else
              FilledButton(
                key: const Key('myForm_submit'),
                onPressed:
                    (_state.circles.firstWhereOrNull((c) => c.$3) != null &&
                            _state.start != null &&
                            _state.location != null &&
                            _state.title.isNotEmpty)
                        ? _onSubmit
                        : null,
                child: const Text('Share'),
              ),
            const SizedBox(height: 16),
          ])));
}

class ScheduleFormState with FormzMixin {
  ScheduleFormState({
    this.title = '',
    this.details = '',
    this.start,
    this.end,
    this.location,
    this.circles = const [],
    this.status = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus status;
  final String title;
  final String details;
  final DateTime? start;
  final DateTime? end;
  final SearchResult? location;
  final List<(String, String, bool, int)> circles;

  ScheduleFormState copyWith({
    DateTime? start,
    DateTime? end,
    SearchResult? location,
    String? title,
    String? details,
    List<(String, String, bool, int)>? circles,
    FormzSubmissionStatus? status,
  }) =>
      ScheduleFormState(
        start: start ?? this.start,
        end: end ?? this.end,
        location: location ?? this.location,
        title: title ?? this.title,
        details: details ?? this.details,
        circles: circles ?? this.circles,
        status: status ?? this.status,
      );

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [];
}

class ScheduleWidget extends StatelessWidget {
  const ScheduleWidget({this.locationId, this.location, super.key});

  final String? locationId;
  final ContactTemporaryLocation? location;

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => ScheduleCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<ScheduleCubit, ScheduleState>(
          listener: (context, state) async {},
          builder: (context, state) {
            final initialFormState = (location == null)
                ? null
                : ScheduleFormState(
                    title: location!.name,
                    details: location!.details,
                    location: SearchResult(
                        longitude: location!.longitude,
                        latitude: location!.latitude,
                        placeName: location!.address ?? '',
                        id: ''),
                    start: location!.start,
                    end: location!.end,
                    circles: state.circles.entries
                        .map((c) => (
                              c.key,
                              c.value,
                              location!.circles.contains(c.key),
                              state.circleMemberships.values
                                  .where((cIds) => cIds.contains(c.key))
                                  .length
                            ))
                        .toList());

            return Scaffold(
                appBar: AppBar(title: const Text('Schedule a visit')),
                body: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      const SizedBox(height: 4),
                      MyForm(
                        circles: state.circles,
                        circleMemberships: state.circleMemberships,
                        callback: (
                                {required name,
                                required details,
                                required address,
                                required start,
                                required end,
                                required coordinates,
                                required circles}) async =>
                            context.read<ScheduleCubit>().schedule(
                                locationId: locationId,
                                name: name,
                                details: details,
                                address: address,
                                start: start,
                                end: end,
                                coordinates: coordinates,
                                circles: circles),
                        initialState: initialFormState,
                      )
                    ])));
          }));
}
