// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:uuid/uuid.dart';

// TODO: Display check in form with location (from gps, from map picker, from address, from coordinates) circles to share with, optional duration, optional move away to check out constraint
class CirclesForm extends StatefulWidget {
  CirclesForm(
      {required this.circles,
      required this.callback,
      this.allowCreateNew = true,
      this.customHeader,
      super.key});

  final Future<void> Function(List<(String, String, bool)>) callback;
  final List<(String, String, bool, int)> circles;
  final bool allowCreateNew;
  final Widget? customHeader;

  @override
  State<CirclesForm> createState() => _CirclesFormState();
}

class _CirclesFormState extends State<CirclesForm> {
  final _key = GlobalKey<FormState>();
  late CirclesFormState _state;
  late final TextEditingController _titleController;

  void _onTitleChanged() {
    setState(() {
      _state = _state.copyWith(newCircleName: _titleController.text);
    });
  }

  void _addNewCircle() {
    // if circle name already exists, add to it, otherwise create new and add to
    final updatedCircles =
        (_state.circles.map((e) => e.$2).contains(_titleController.text))
            ? _state.circles.map((e) =>
                (e.$2 == _titleController.text) ? (e.$1, e.$2, true, e.$4) : e)
            : [
                (const Uuid().v4(), _titleController.text, true, 0),
                ..._state.circles
              ];
    setState(() {
      _state = _state.copyWith(circles: updatedCircles.asList());
    });
    _titleController.clear();
  }

  void _updateCircleMembership(int i, bool state) {
    final circles = List<(String, String, bool, int)>.from(_state.circles);
    circles[i] = (circles[i].$1, circles[i].$2, state, circles[i].$4);
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
      // In case someone entered a new circle name and submitted before adding
      // the new circle explicitly, still add it
      if (_titleController.text.isNotEmpty) {
        _addNewCircle();
      }
      unawaited(widget
          .callback(_state.circles.map((c) => (c.$1, c.$2, c.$3)).toList()));
      _state = _state.copyWith(status: FormzSubmissionStatus.success);
      Navigator.pop(context);
    } catch (e) {
      _state = _state.copyWith(status: FormzSubmissionStatus.failure);
    }

    if (!mounted) return;

    setState(() {});

    FocusScope.of(context)
      ..nextFocus()
      ..unfocus();

    const failureSnackBar = SnackBar(
      content: Text('Something went wrong... 🚨'),
    );

    if (!_state.status.isSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(failureSnackBar);
    }

    if (_state.status.isSuccess) _resetForm();
  }

  void _resetForm() {
    _key.currentState!.reset();
    _titleController.clear();
    setState(() => _state = CirclesFormState());
  }

  @override
  void initState() {
    super.initState();
    _state = CirclesFormState(circles: widget.circles);
    _titleController = TextEditingController(text: _state.newCircleName)
      ..addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
      key: _key,
      child: Column(children: [
        const Align(
            alignment: Alignment.centerLeft,
            child:
                Text('Circle memberships', textScaler: TextScaler.linear(1.2))),
        if (widget.customHeader != null) widget.customHeader!,
        if (widget.allowCreateNew)
          Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  key: const Key('circlesForm_newCircleInput'),
                  controller: _titleController,
                  // TODO: Make this a search or create new circle
                  decoration: const InputDecoration(
                    helperText: 'Create a new circle',
                    helperMaxLines: 2,
                    labelText: 'New Circle',
                    errorMaxLines: 2,
                  ),
                  textInputAction: TextInputAction.done,
                )),
                IconButton(
                  key: const Key('circlesForm_submitNewCircle'),
                  onPressed:
                      (_titleController.text.isEmpty) ? null : _addNewCircle,
                  icon: const Icon(Icons.add),
                ),
              ])),
        // If we don't need wrapping but go for a list, use CheckboxListTile
        Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _state.circles
                .asMap()
                .map((i, c) => MapEntry(
                    i,
                    GestureDetector(
                        onTap: () => _updateCircleMembership(i, !c.$3),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(value: c.$3, onChanged: (_) {}),
                            Text('${c.$2} (${c.$4})'),
                            const SizedBox(width: 4),
                          ],
                        ))))
                .values
                .asList()),
        const SizedBox(height: 8, width: double.maxFinite),
        if (_state.status.isInProgress)
          const CircularProgressIndicator()
        else
          FilledButton(
            key: const Key('circlesForm_submit'),
            onPressed: _onSubmit,
            child: const Text('Save'),
          ),
        const SizedBox(height: 16),
      ]));
}

class CirclesFormState with FormzMixin {
  CirclesFormState({
    this.newCircleName = '',
    this.circles = const [],
    this.status = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus status;
  final String newCircleName;
  final List<(String, String, bool, int)> circles;

  CirclesFormState copyWith({
    String? newCircleName,
    List<(String, String, bool, int)>? circles,
    FormzSubmissionStatus? status,
  }) =>
      CirclesFormState(
        newCircleName: newCircleName ?? this.newCircleName,
        circles: circles ?? this.circles,
        status: status ?? this.status,
      );

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [];
}
