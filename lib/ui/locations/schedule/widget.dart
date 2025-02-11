// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

import '../../../data/repositories/contacts.dart';
import 'cubit.dart';

class MyForm extends StatefulWidget {
  const MyForm(
      {required this.callback,
      super.key,
      this.circles = const {},
      this.circleMemberships = const {}});

  final Future<void> Function({
    required String name,
    required String details,
    required DateTime start,
    required DateTime end,
    required LatLng coordinates,
    required List<String> circles,
  }) callback;

  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _key = GlobalKey<FormState>();
  late MyFormState _state;
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;

  void _onTitleChanged() {
    setState(() {
      _state = _state.copyWith(title: _titleController.text);
    });
  }

  void _onDetailsChanged() {
    setState(() {
      _state = _state.copyWith(details: _detailsController.text);
    });
  }

  void _onStartTimeChanged(TimeOfDay value) {
    setState(() {
      _state = _state.copyWith(
          start: DateTime(_state.start!.year, _state.start!.month,
              _state.start!.day, value.hour, value.minute));
    });
  }

  void _onEndTimeChanged(TimeOfDay value) {
    setState(() {
      _state = _state.copyWith(
          end: DateTime(_state.end!.year, _state.end!.month, _state.end!.day,
              value.hour, value.minute));
    });
  }

  void _onLocationChanged(PickedData value) {
    setState(() {
      _state = _state.copyWith(location: value);
    });
  }

  void _onDateRangeChanged(DateTimeRange value) {
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
    final circles = List<(String, String, bool, int)>.from(_state.circles);
    circles[i] = (circles[i].$1, circles[i].$2, selected, circles[i].$4);
    setState(() {
      _state = _state.copyWith(circles: circles);
    });
  }

  Future<void> _onSubmit() async {
    if (!_key.currentState!.validate()) return;

    setState(() {
      _state = _state.copyWith(status: FormzSubmissionStatus.inProgress);
    });

    try {
      await widget.callback(
          name: _state.title,
          details: (_state.details.isEmpty)
              ? _state.location!.address
              : '${_state.location!.address}\n${_state.details}',
          circles: _state.circles.where((c) => c.$3).map((c) => c.$1).toList(),
          start: _state.start!,
          end: _state.end!,
          coordinates: _state.location!.latLong.toLatLng());
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
  void initState() {
    super.initState();
    _state = MyFormState(
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
                  Text('Circles to share with',
                      textScaler: TextScaler.linear(1.1))
                ])),
            Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _state.circles
                    .asMap()
                    .map((i, c) => MapEntry(
                        i,
                        (c.$3)
                            ? FilledButton(
                                onPressed: () =>
                                    _updateCircleSelection(i, false),
                                child: Text('${c.$2} (${c.$4})'))
                            : OutlinedButton(
                                onPressed: () =>
                                    _updateCircleSelection(i, true),
                                child: Text('${c.$2} (${c.$4})'))))
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
                child: FlutterLocationPicker(
                  initZoom: 6,
                  minZoomLevel: 5,
                  maxZoomLevel: 16,
                  initPosition: _state.location?.latLong ??
                      const LatLong(48.8575, 2.3514),
                  searchBarBackgroundColor: Colors.white,
                  mapLanguage: 'en',
                  onError: (e) => print(e),
                  selectLocationButtonLeadingIcon: const Icon(Icons.check),
                  onPicked: _onLocationChanged,
                  onChanged: _onLocationChanged,
                  selectLocationButtonText: 'Pick Location',
                  showLocationController: false,
                  showCurrentLocationPointer: false,
                  trackMyPosition: false,
                  selectLocationButtonHeight: 0,
                  selectLocationButtonWidth: 0,
                  showContributorBadgeForOSM: true,
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

class MyFormState with FormzMixin {
  MyFormState({
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
  final PickedData? location;
  final List<(String, String, bool, int)> circles;

  MyFormState copyWith({
    DateTime? start,
    DateTime? end,
    PickedData? location,
    String? title,
    String? details,
    List<(String, String, bool, int)>? circles,
    FormzSubmissionStatus? status,
  }) =>
      MyFormState(
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
  const ScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => ScheduleCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<ScheduleCubit, ScheduleState>(
          listener: (context, state) async {},
          builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Schedule Visit')),
              body: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const SizedBox(height: 4),
                    MyForm(
                        circles: state.circles,
                        circleMemberships: state.circleMemberships,
                        callback: context.read<ScheduleCubit>().schedule)
                  ])))));
}
