// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../data/repositories/contacts.dart';
import 'cubit.dart';

// TODO: Display check in form with location (from gps, from map picker, from address, from coordinates) circles to share with, optional duration, optional move away to check out constraint
class MyForm extends StatefulWidget {
  const MyForm(
      {required this.callback,
      super.key,
      this.circles = const {},
      this.circleMemberships = const {}});

  final Future<void> Function({
    required String name,
    required String details,
    required List<String> circles,
    required DateTime end,
  }) callback;

  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  @override
  State<MyForm> createState() => _MyFormState();
}

class MultipleOf15InputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue; // Allow empty input
    }

    // Check if input is a valid positive multiple of 15 (including 0)
    final parsedValue = int.tryParse(newValue.text);
    if (parsedValue != null && parsedValue >= 0 && parsedValue % 15 == 0) {
      return newValue;
    }

    // Reject input if invalid
    return oldValue;
  }
}

class _MyFormState extends State<MyForm> {
  final _key = GlobalKey<FormState>();
  late MyFormState _state;
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

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

  void _onTimeChanged() {
    setState(() {
      _state = _state.copyWith(
          hours: int.tryParse(_hoursController.text) ?? 0,
          minutes: int.tryParse(_minutesController.text) ?? 0);
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
          name: (_state.title.isEmpty) ? 'Checked-in' : _state.title,
          details: _state.details,
          circles: _state.circles.where((c) => c.$3).map((c) => c.$1).toList(),
          end: DateTime.now().add(Duration(
              hours: _hoursController.text.isEmpty
                  ? 0
                  : int.parse(_hoursController.text),
              minutes: _minutesController.text.isEmpty
                  ? 0
                  : int.parse(_minutesController.text))));
      _state = _state.copyWith(status: FormzSubmissionStatus.success);
      // Navigator.pop(context);
    } catch (e) {
      _state = _state.copyWith(status: FormzSubmissionStatus.failure);
    }

    if (!mounted) return;

    if (!_state.status.isSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
              content: Text('Could not determine current GPS location')),
        );
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      _resetForm();
    }
  }

  void _resetForm() {
    _key.currentState!.reset();
    _titleController.clear();
    _detailsController.clear();
    _hoursController.clear();
    _minutesController.clear();
    setState(() => _state = MyFormState());
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
    _hoursController = TextEditingController()..addListener(_onTimeChanged);
    _minutesController = TextEditingController()..addListener(_onTimeChanged);
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Share current location',
                textScaler: const TextScaler.linear(1.6),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('checkInForm_titleInput'),
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                helperMaxLines: 2,
                labelText: 'Title',
                errorMaxLines: 2,
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('checkInForm_detailsInput'),
              controller: _detailsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                helperMaxLines: 2,
                labelText: 'Description',
                errorMaxLines: 2,
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Row(children: [
              Text('with circles', textScaler: TextScaler.linear(1.2))
            ]),
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
            const SizedBox(height: 4),
            const Text('for duration', textScaler: TextScaler.linear(1.2)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      key: const Key('checkInForm_hours'),
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Hours',
                        border: OutlineInputBorder(),
                      ))),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':')),
              Expanded(
                  child: TextFormField(
                      key: const Key('checkInForm_minutes'),
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ))),
            ]),
            const SizedBox(height: 16),
            if (_state.status.isInProgress)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                  child: FilledButton(
                key: const Key('checkInForm_submit'),
                onPressed:
                    (_state.circles.firstWhereOrNull((c) => c.$3) != null &&
                            (_state.hours > 0 || _state.minutes > 0) &&
                            _state.title.isNotEmpty)
                        ? _onSubmit
                        : null,
                child: const Text('Share'),
              )),
            const SizedBox(height: 16),
          ])));
}

class MyFormState with FormzMixin {
  MyFormState({
    this.hours = 0,
    this.minutes = 0,
    this.title = '',
    this.details = '',
    this.circles = const [],
    this.status = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus status;
  final String title;
  final String details;
  final int hours;
  final int minutes;
  final List<(String, String, bool, int)> circles;

  MyFormState copyWith({
    int? hours,
    int? minutes,
    String? title,
    String? details,
    List<(String, String, bool, int)>? circles,
    FormzSubmissionStatus? status,
  }) =>
      MyFormState(
        hours: hours ?? this.hours,
        minutes: minutes ?? this.minutes,
        title: title ?? this.title,
        details: details ?? this.details,
        circles: circles ?? this.circles,
        status: status ?? this.status,
      );

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [];
}

class CheckInWidget extends StatelessWidget {
  const CheckInWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => CheckInCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<CheckInCubit, CheckInState>(
          listener: (context, state) async {},
          builder: (context, state) {
            if (state.status.isInitial) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: const Center(child: CircularProgressIndicator()));
            }

            // TODO: Instead of these two error cases, just show manual location picker in form
            if (state.status.isLocationDenied ||
                state.status.isLocationDeniedPermanent) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 32, top: 8),
                      child: Text(
                          'Location permission denied. Please grant Coagulate location access.')));
            }
            if (state.status.isLocationDisabled) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 32, top: 8),
                      child: Text(
                          'Location services seem to be disabled, GPS based check-in is not possible.')));
            }
            if (state.status.isLocationTimeout) {
              // TODO: Display error and leave filled out form in place
              // optionally, switch form to manual location choice
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 32, top: 8),
                      child: Text(
                          'Could not determine GPS location, please try again.')));
            }

            // TODO: What to do on success?
            // Navigator.pop(context);

            return MyForm(
                circles: state.circles,
                circleMemberships: state.circleMemberships,
                callback: context.read<CheckInCubit>().checkIn);
          }));
}
