// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/contacts.dart';
import 'cubit.dart';

// TODO: Display check in form with location (from gps, from map picker, from address, from coordinates) circles to share with, optional duration, optional move away to check out constraint
class CirclesForm extends StatefulWidget {
  CirclesForm({super.key, required this.circles, required this.callback});

  final void Function(List<(String, String, bool)>) callback;
  final List<(String, String, bool)> circles;

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
    final updatedCircles = (_state.circles
            .map((e) => e.$2)
            .contains(_titleController.text))
        ? _state.circles.map(
            (e) => (e.$2 == _titleController.text) ? (e.$1, e.$2, true) : e)
        : [(const Uuid().v4(), _titleController.text, true), ..._state.circles];
    setState(() {
      _state = _state.copyWith(circles: updatedCircles.asList());
    });
    _titleController.clear();
  }

  void _updateCircleMembership(int i, bool state) {
    setState(() {
      var circles = List<(String, String, bool)>.from(_state.circles);
      circles[i] = (circles[i].$1, circles[i].$2, state);
      _state = _state.copyWith(circles: circles);
    });
  }

  Future<void> _onSubmit() async {
    if (!_key.currentState!.validate()) return;

    setState(() {
      _state = _state.copyWith(status: FormzSubmissionStatus.inProgress);
    });

    try {
      widget.callback(_state.circles);
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

    const successSnackBar = SnackBar(
      content: Text('Submitted successfully! 🎉'),
    );
    const failureSnackBar = SnackBar(
      content: Text('Something went wrong... 🚨'),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _state.status.isSuccess ? successSnackBar : failureSnackBar,
      );

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
        child: Column(
          children: [
            Row(children: [
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
                onPressed: _addNewCircle,
                icon: const Icon(Icons.add),
              ),
            ]),
            const SizedBox(height: 16),
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
                                    _updateCircleMembership(i, false),
                                child: Text(c.$2))
                            : OutlinedButton(
                                onPressed: () =>
                                    _updateCircleMembership(i, true),
                                child: Text(c.$2))))
                    .values
                    .asList()),
            const SizedBox(height: 8),
            if (_state.status.isInProgress)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                key: const Key('circlesForm_submit'),
                onPressed: _onSubmit,
                child: const Text('Save'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      );
}

class CirclesFormState with FormzMixin {
  CirclesFormState({
    this.newCircleName = '',
    this.circles = const [],
    this.status = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus status;
  final String newCircleName;
  final List<(String, String, bool)> circles;

  CirclesFormState copyWith({
    String? newCircleName,
    List<(String, String, bool)>? circles,
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

class CirclesWidget extends StatelessWidget {
  const CirclesWidget({super.key, required this.coagContactId});

  final String coagContactId;

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) =>
          CirclesCubit(context.read<ContactsRepository>(), coagContactId),
      child: BlocConsumer<CirclesCubit, CirclesState>(
          listener: (context, state) async {},
          builder: (context, state) => ElevatedButton(
              onPressed: () async => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (modalContext) => Padding(
                      padding: EdgeInsets.only(
                          left: 16,
                          top: 16,
                          right: 16,
                          bottom:
                              MediaQuery.of(modalContext).viewInsets.bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CirclesForm(
                              circles: state.circles,
                              callback: context.read<CirclesCubit>().update)
                        ],
                      ))),
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pin_drop),
                    SizedBox(width: 8),
                    Text('check-in')
                  ]))));
}
