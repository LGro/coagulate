// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_sharing_settings.dart';
import '../../data/providers/geocoding/maptiler.dart';
import '../../data/repositories/contacts.dart';
import '../locations/schedule/widget.dart';
import '../utils.dart';
import 'cubit.dart';

Future<void> pickCirclePicture(BuildContext context,
    Future<void> Function(Uint8List picture) handlePicture) async {
  try {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );
    if (context.mounted && pickedFile != null) {
      final p = await pickedFile.readAsBytes();
      await handlePicture(p);
    }
  } catch (e) {
    // TODO: Handle
    print(e);
  }
}

class CirclesWithAvatarWidget extends StatefulWidget {
  const CirclesWithAvatarWidget({
    super.key,
    required this.circles,
    required this.title,
    required this.pictures,
    required this.circleMemberCount,
    this.editCallback,
    this.deleteCallback,
  });

  final Text title;
  final Map<String, Uint8List> pictures;
  final Map<String, String> circles;
  final Map<String, int> circleMemberCount;
  final void Function(String circleId, Uint8List picture)? editCallback;
  final void Function(String circleId)? deleteCallback;

  @override
  State<CirclesWithAvatarWidget> createState() =>
      _CirclesWithAvatarWidgetState();
}

class _CirclesWithAvatarWidgetState extends State<CirclesWithAvatarWidget> {
  // TODO: Is local state management even necessary?
  Map<String, Uint8List> _pictures = {};

  @override
  void initState() {
    super.initState();
    _pictures = widget.pictures;
  }

  @override
  Widget build(BuildContext context) => Column(
      children: _card(
          title: widget.title,
          children: <Widget>[const SizedBox(height: 6)] +
              widget.circles
                  .map((circleId, circleLabel) => MapEntry<String, Widget>(
                      circleId,
                      Dismissible(
                          key: Key('picture|$circleId'),
                          direction: (widget.deleteCallback != null)
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          confirmDismiss: (widget.deleteCallback != null)
                              ? (_) async {
                                  widget.deleteCallback!(circleId);
                                  setState(() {
                                    _pictures = _pictures..remove(circleId);
                                  });
                                  // Ensure the UI element is not actually removed
                                  return false;
                                }
                              : null,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async =>
                                  pickCirclePicture(context, (p) async {
                                    final _updatedPictures = {..._pictures};
                                    _updatedPictures[circleId] = p;
                                    if (context.mounted) {
                                      await context
                                          .read<ProfileCubit>()
                                          .updateAvatar(circleId, p);
                                    }
                                    setState(() {
                                      _pictures = _updatedPictures;
                                    });
                                  }),
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(children: [
                                    if (!_pictures.containsKey(circleId))
                                      const CircleAvatar(
                                          radius: 48,
                                          child: Icon(Icons.person)),
                                    if (_pictures.containsKey(circleId))
                                      CircleAvatar(
                                        backgroundImage:
                                            MemoryImage(_pictures[circleId]!),
                                        radius: 48,
                                      ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        //FIXME: Overflow / wrapping for long circle names
                                        child: Text(
                                            'Circle: $circleLabel\nShared with '
                                            '${widget.circleMemberCount[circleId] ?? 0} '
                                            'contact${(widget.circleMemberCount[circleId] == 1) ? '' : 's'}',
                                            softWrap: true)),
                                  ]))))))
                  .values
                  .asList() +
              [
                const SizedBox(height: 8),
                Text(context.loc.profilePictureExplainer),
                const SizedBox(height: 4),
              ]));
}

// TODO: Pass other labels to prevent duplicates
class EditOrAddWidget extends StatefulWidget {
  const EditOrAddWidget({
    super.key,
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    this.value,
    this.label,
    this.onDelete,
    this.valueHintText,
    this.labelHelperText,
    this.hideLabel = false,
    this.existingLabels = const [],
  });

  final bool isEditing;
  final bool hideLabel;
  final String headlineSuffix;
  final String? labelHelperText;
  final String? valueHintText;
  final String? label;
  final String? value;
  final VoidCallback? onDelete;
  final void Function(String label, String value,
      List<(String, String, bool)> selectedCircles) onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<EditOrAddWidget> createState() => _EditOrAddWidgetState();
}

class _EditOrAddWidgetState extends State<EditOrAddWidget> {
  final _formKey = GlobalKey<FormState>();
  final _valueFieldKey = GlobalKey<FormFieldState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  String? _value;
  String? _label;

  @override
  void initState() {
    super.initState();
    _circles = [...widget.circles];
    _newCircleNameController = TextEditingController();
    _value = widget.value;
    _label = widget.label;
  }

  @override
  void dispose() {
    _newCircleNameController.dispose();
    super.dispose();
  }

  void _addNewCircle() {
    if (_newCircleNameController.text.trim().isNotEmpty &&
        !_circles.any((e) => e.$2 == _newCircleNameController.text.trim())) {
      setState(() {
        _circles.insert(0,
            (const Uuid().v4(), _newCircleNameController.text.trim(), true, 0));
      });
      _newCircleNameController.clear();
    }
  }

  void _updateCircleMembership(int index, bool isSelected) {
    setState(() {
      _circles[index] = (
        _circles[index].$1,
        _circles[index].$2,
        isSelected,
        _circles[index].$4
      );
    });
  }

  @override
  Widget build(BuildContext context) => Form(
      key: _formKey,
      child: buildEditOrAddWidgetSkeleton(
        context,
        title: (widget.isEditing)
            ? context.loc.profileEditHeadline(widget.headlineSuffix)
            : context.loc.profileAddHeadline(widget.headlineSuffix),
        onSaveWidget: IconButton.filledTonal(
            onPressed: () => (_formKey.currentState!.validate())
                ? widget.onAddOrSave(
                    (_label ?? '').trim(),
                    (_value ?? '').trim(),
                    _circles.map((e) => (e.$1, e.$2, e.$3)).toList())
                : null,
            icon: const Icon(Icons.save)),
        children: [
          if (!widget.hideLabel) ...[
            const SizedBox(height: 8),
            FractionallySizedBox(
                widthFactor: 0.5,
                child: TextFormField(
                  key: _labelFieldKey,
                  initialValue: _label,
                  decoration: InputDecoration(
                    labelText: 'label',
                    isDense: true,
                    helperText: widget.labelHelperText,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please specify a label.';
                    }
                    if (widget.existingLabels
                        .map((l) => l.toLowerCase())
                        .contains(value?.toLowerCase())) {
                      return 'This label already exists.';
                    }
                    return null;
                  },
                  onChanged: (label) {
                    if (_labelFieldKey.currentState?.validate() ?? false) {
                      setState(() {
                        _label = label;
                      });
                    }
                  },
                )),
            const SizedBox(height: 16),
          ],
          TextFormField(
            key: _valueFieldKey,
            initialValue: _value,
            autocorrect: false,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.valueHintText ?? widget.headlineSuffix,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if ((_label?.isNotEmpty ?? false) && (value?.isEmpty ?? true)) {
                return 'Please enter a value.';
              }
              return null;
            },
            onChanged: (value) {
              if (_valueFieldKey.currentState?.validate() ?? false) {
                setState(() {
                  _value = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),
          Text(
            context.loc.profileAndShareWithHeadline,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          // If we don't need wrapping but go for a list, use CheckboxListTile
          Wrap(
            spacing: 8,
            runSpacing: -4,
            children: List.generate(
                _circles.length,
                (index) => GestureDetector(
                    onTap: () =>
                        _updateCircleMembership(index, !_circles[index].$3),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                            value: _circles[index].$3,
                            onChanged: (value) => (value == null)
                                ? null
                                : _updateCircleMembership(index, value)),
                        Text('${_circles[index].$2} (${_circles[index].$4})'),
                        const SizedBox(width: 4),
                      ],
                    ))),
          ),
          // const SizedBox(height: 8),
          // Row(children: [
          //   Expanded(
          //       child: TextField(
          //     controller: _newCircleNameController,
          //     decoration: InputDecoration(
          //       isDense: true,
          //       labelText: context.loc.newCircle,
          //       border: const OutlineInputBorder(),
          //     ),
          //   )),
          //   const SizedBox(width: 8),
          //   FilledButton.tonal(
          //     onPressed: _addNewCircle,
          //     child: Text(context.loc.add.capitalize()),
          //   ),
          // ]),
          const SizedBox(height: 16),
          if (widget.onDelete != null)
            Center(
                child: TextButton(
                    onPressed: widget.onDelete,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error),
                    ),
                    child: Text(
                      'Remove ${widget.headlineSuffix}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ))),
        ],
      ));
}

// TODO: Tackle redundancies with other details add or edit widget
class EditOrAddAddressWidget extends StatefulWidget {
  const EditOrAddAddressWidget({
    super.key,
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    this.value,
    this.label,
    this.onDelete,
    this.valueHintText,
    this.labelHelperText,
    this.existingLabels = const [],
  });

  final bool isEditing;
  final String headlineSuffix;
  final String? labelHelperText;
  final String? valueHintText;
  final String? label;
  final ContactAddressLocation? value;
  final VoidCallback? onDelete;
  final void Function(String?, String label, ContactAddressLocation value,
      List<(String, String, bool)> selectedCircles) onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<EditOrAddAddressWidget> createState() => _EditOrAddAddressWidgetState();
}

class _EditOrAddAddressWidgetState extends State<EditOrAddAddressWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  ContactAddressLocation? _value;
  String? _label;

  @override
  void initState() {
    super.initState();
    _circles = [...widget.circles];
    _newCircleNameController = TextEditingController();
    _value = widget.value;
    _label = widget.label;
  }

  @override
  void dispose() {
    _newCircleNameController.dispose();
    super.dispose();
  }

  void _updateCircleMembership(int index, bool isSelected) {
    setState(() {
      _circles[index] = (
        _circles[index].$1,
        _circles[index].$2,
        isSelected,
        _circles[index].$4
      );
    });
  }

  @override
  Widget build(BuildContext context) => Form(
      key: _formKey,
      child: buildEditOrAddWidgetSkeleton(
        context,
        title: (widget.isEditing)
            ? context.loc.profileEditHeadline(widget.headlineSuffix)
            : context.loc.profileAddHeadline(widget.headlineSuffix),
        onSaveWidget: IconButton.filledTonal(
            onPressed: () =>
                (_formKey.currentState!.validate() && _value != null)
                    ? widget.onAddOrSave(
                        widget.label,
                        (_label ?? '').trim(),
                        _value!,
                        _circles.map((e) => (e.$1, e.$2, e.$3)).toList())
                    : null,
            icon: const Icon(Icons.save)),
        children: [
          FractionallySizedBox(
              widthFactor: 0.5,
              child: TextFormField(
                key: _labelFieldKey,
                initialValue: _label,
                decoration: InputDecoration(
                  labelText: 'label',
                  isDense: true,
                  helperText: widget.labelHelperText,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please specify a label.';
                  }
                  if (widget.existingLabels
                      .map((l) => l.toLowerCase())
                      .contains(value?.toLowerCase())) {
                    return 'This label already exists.';
                  }
                  return null;
                },
                onChanged: (label) {
                  if (_labelFieldKey.currentState?.validate() ?? false) {
                    setState(() {
                      _label = label;
                    });
                  }
                },
              )),
          const SizedBox(height: 16),
          // TODO: Validate empty field with hint?
          SizedBox(
              height: 350,
              child: MapWidget(
                  initialLocation: (_value == null)
                      ? null
                      : SearchResult(
                          longitude: _value!.longitude,
                          latitude: _value!.latitude,
                          placeName: _value!.address ?? '',
                          id: ''),
                  onSelected: (l) {
                    setState(() {
                      _value = ContactAddressLocation(
                          longitude: l.longitude,
                          latitude: l.latitude,
                          address: l.placeName);
                    });
                  })),
          const SizedBox(height: 16),
          Text(
            context.loc.profileAndShareWithHeadline,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          // If we don't need wrapping but go for a list, use CheckboxListTile
          Wrap(
            spacing: 8,
            runSpacing: -4,
            children: List.generate(
                _circles.length,
                (index) => GestureDetector(
                    onTap: () =>
                        _updateCircleMembership(index, !_circles[index].$3),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                            value: _circles[index].$3,
                            onChanged: (value) => (value == null)
                                ? null
                                : _updateCircleMembership(index, value)),
                        Text('${_circles[index].$2} (${_circles[index].$4})'),
                        const SizedBox(width: 4),
                      ],
                    ))),
          ),
          const SizedBox(height: 16),
          if (widget.onDelete != null)
            Center(
                child: TextButton(
                    onPressed: widget.onDelete,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error),
                    ),
                    child: Text(
                      'Remove ${widget.headlineSuffix}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ))),
        ],
      ));
}

// TODO: Tackle redundancies with other details add or edit widget
class EditOrAddEventWidget extends StatefulWidget {
  const EditOrAddEventWidget({
    super.key,
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    this.value,
    this.label,
    this.onDelete,
    this.valueHintText,
    this.labelHelperText,
    this.existingLabels = const [],
  });

  final bool isEditing;
  final String headlineSuffix;
  final String? labelHelperText;
  final String? valueHintText;
  final String? label;
  final String? value;
  final VoidCallback? onDelete;
  final void Function(String? oldLabel, String label, DateTime value,
      List<(String, String, bool)> selectedCircles) onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<EditOrAddEventWidget> createState() => _EditOrAddEventWidgetState();
}

class _EditOrAddEventWidgetState extends State<EditOrAddEventWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  final _valueFieldKey = GlobalKey<FormFieldState>();
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  String? _value;
  String? _label;

  @override
  void initState() {
    super.initState();
    _circles = [...widget.circles];
    _newCircleNameController = TextEditingController();
    _value = widget.value;
    _label = widget.label;
  }

  @override
  void dispose() {
    _newCircleNameController.dispose();
    super.dispose();
  }

  void _updateCircleMembership(int index, bool isSelected) {
    setState(() {
      _circles[index] = (
        _circles[index].$1,
        _circles[index].$2,
        isSelected,
        _circles[index].$4
      );
    });
  }

  @override
  Widget build(BuildContext context) => Form(
      key: _formKey,
      child: buildEditOrAddWidgetSkeleton(
        context,
        title: (widget.isEditing)
            ? context.loc.profileEditHeadline(widget.headlineSuffix)
            : context.loc.profileAddHeadline(widget.headlineSuffix),
        onSaveWidget: IconButton.filledTonal(
            onPressed: () =>
                (_formKey.currentState!.validate() && _value != null)
                    ? widget.onAddOrSave(
                        widget.label,
                        (_label ?? '').trim(),
                        DateTime.parse(_value!),
                        _circles.map((e) => (e.$1, e.$2, e.$3)).toList())
                    : null,
            icon: const Icon(Icons.save)),
        children: [
          FractionallySizedBox(
              widthFactor: 0.5,
              child: TextFormField(
                key: _labelFieldKey,
                initialValue: _label,
                decoration: InputDecoration(
                  labelText: 'label',
                  isDense: true,
                  helperText: widget.labelHelperText,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please specify a label.';
                  }
                  if (widget.existingLabels
                      .map((l) => l.toLowerCase())
                      .contains(value?.toLowerCase())) {
                    return 'This label already exists.';
                  }
                  return null;
                },
                onChanged: (label) {
                  if (_labelFieldKey.currentState?.validate() ?? false) {
                    setState(() {
                      _label = label;
                    });
                  }
                },
              )),
          const SizedBox(height: 16),
          TextFormField(
            key: _valueFieldKey,
            initialValue: _value,
            autocorrect: false,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.valueHintText ?? widget.headlineSuffix,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if ((_label?.isNotEmpty ?? false) && (value?.isEmpty ?? true)) {
                return 'Please enter a value.';
              } else if (DateTime.tryParse(value!) == null) {
                return 'Please enter a date in the format YYYY-MM-DD';
              }
              return null;
            },
            onChanged: (value) {
              if (_valueFieldKey.currentState?.validate() ?? false) {
                setState(() {
                  _value = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            context.loc.profileAndShareWithHeadline,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          // If we don't need wrapping but go for a list, use CheckboxListTile
          Wrap(
            spacing: 8,
            runSpacing: -4,
            children: List.generate(
                _circles.length,
                (index) => GestureDetector(
                    onTap: () =>
                        _updateCircleMembership(index, !_circles[index].$3),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                            value: _circles[index].$3,
                            onChanged: (value) => (value == null)
                                ? null
                                : _updateCircleMembership(index, value)),
                        Text('${_circles[index].$2} (${_circles[index].$4})'),
                        const SizedBox(width: 4),
                      ],
                    ))),
          ),
          const SizedBox(height: 16),
          if (widget.onDelete != null)
            Center(
                child: TextButton(
                    onPressed: widget.onDelete,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error),
                    ),
                    child: Text(
                      'Remove ${widget.headlineSuffix}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ))),
        ],
      ));
}

List<Widget> _card({Text? title, List<Widget> children = const []}) => [
      if (title != null)
        Row(children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
              child: title)
        ]),
      Card(
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ))),
    ];

List<Widget> detailsList(
  BuildContext context,
  Map<String, String> details, {
  Text? title,
  Map<String, String>? circles,
  Map<String, List<String>>? circleMemberships,
  List<String>? Function(String label)? getDetailSharingSettings,
  void Function(String label)? editCallback,
  VoidCallback? addCallback,
  void Function(String label)? deleteCallback,
  bool hideLabel = false,
  bool hideEditButton = false,
}) =>
    _card(
        title: title,
        children: details
                .map((label, value) {
                  final circleNames =
                      (circles == null || getDetailSharingSettings == null)
                          ? null
                          : circles.entries
                              .where((c) =>
                                  getDetailSharingSettings(label)
                                      ?.contains(c.key) ??
                                  false)
                              .map((c) => c.value)
                              .toList();

                  final numSharedContacts = (circles == null ||
                          getDetailSharingSettings == null ||
                          circleMemberships == null)
                      ? null
                      : circleMemberships.values
                          .where((contactCircleIds) => contactCircleIds
                              .toSet()
                              .intersectsWith(
                                  getDetailSharingSettings(label)?.toSet() ??
                                      {}))
                          .length;

                  return MapEntry<String, Widget>(
                    label,
                    Dismissible(
                      key: Key('$title|$label'),
                      direction: (deleteCallback != null)
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      onDismissed: (deleteCallback != null)
                          ? (_) => deleteCallback(label)
                          : null,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (editCallback == null)
                            ? null
                            : () => editCallback(label),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    if (!hideLabel)
                                      Text(label,
                                          textScaler:
                                              const TextScaler.linear(1.1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                    Text(value,
                                        textScaler:
                                            const TextScaler.linear(1.1),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines:
                                            value.contains('\n') ? null : 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                height: value.contains('\n')
                                                    ? 1.2
                                                    : null)),
                                    if (circleNames != null &&
                                        numSharedContacts != null)
                                      Text(
                                          textScaler:
                                              const TextScaler.linear(1.1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          [
                                            context.loc.sharedWith.capitalize(),
                                            numSharedContacts.toString(),
                                            if (numSharedContacts != 1)
                                              context.loc.contacts
                                            else
                                              context.loc.contact,
                                          ].join(' ')),
                                    if (circleNames?.isNotEmpty ?? false)
                                      Text(
                                        textScaler:
                                            const TextScaler.linear(1.1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        'Circle${(circleNames!.length != 1) ? 's' : ''}: '
                                        '${circleNames.join(', ')}',
                                      ),
                                  ])),
                              if (editCallback != null && !hideEditButton)
                                IconButton.filledTonal(
                                    onPressed: () => editCallback(label),
                                    icon: const Icon(Icons.edit),
                                    iconSize: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .values
                .asList()
                .addBetween(const SizedBox(height: 8)) +
            [
              if (addCallback != null) ...[
                const SizedBox(height: 8),
                Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton.filled(
                        onPressed: addCallback, icon: const Icon(Icons.add))),
              ]
            ]);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(context.read<ContactsRepository>()),
        child: const ProfileView(),
      );
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

Future<void> onAddDetail(
        {required BuildContext context,
        required String headlineSuffix,
        required Map<String, String> circles,
        required Map<String, List<String>> circleMemberships,
        required Future<void> Function(String label, String value,
                List<(String, String, bool)> selectedCircles)
            onAdd,
        String? defaultLabel,
        String? valueHintText,
        String? labelHelperText,
        List<String> existingLabels = const []}) async =>
    showModalBottomSheet<void>(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (buildContext) => DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            initialChildSize: 0.9,
            builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: EditOrAddWidget(
                    isEditing: false,
                    circles: circles
                        .map((cId, cLabel) => MapEntry(cId, (
                              cId,
                              cLabel,
                              false,
                              circleMemberships.values
                                  .where((circles) => circles.contains(cId))
                                  .length
                            )))
                        .values
                        .toList(),
                    headlineSuffix: headlineSuffix,
                    valueHintText: valueHintText,
                    labelHelperText: labelHelperText,
                    label: defaultLabel,
                    existingLabels: existingLabels,
                    onAddOrSave: (label, number, circlesWithSelection) async =>
                        onAdd(label, number, circlesWithSelection).then((_) =>
                            (buildContext.mounted)
                                ? Navigator.of(buildContext).pop()
                                : {})))));

Future<void> onEditDetail({
  required BuildContext context,
  required String headlineSuffix,
  required String label,
  required String value,
  required Map<String, String> circles,
  required Map<String, List<String>> circleMemberships,
  required Map<String, List<String>> detailSharingSettings,
  required Future<void> Function(String oldLabel, String label, String value,
          List<(String, String, bool)> circlesWithSelection)
      onSave,
  required Future<void> Function() onDelete,
  String? valueHintText,
  String? labelHelperText,
  bool hideLabel = false,
  List<String> existingLabels = const [],
}) async =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (buildContext) => DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            initialChildSize: 0.9,
            builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: EditOrAddWidget(
                    isEditing: true,
                    circles: circles
                        .map((cId, cLabel) => MapEntry(cId, (
                              cId,
                              cLabel,
                              detailSharingSettings[label]?.contains(cId) ??
                                  false,
                              circleMemberships.values
                                  .where((circles) => circles.contains(cId))
                                  .length
                            )))
                        .values
                        .toList(),
                    headlineSuffix: headlineSuffix,
                    valueHintText: valueHintText,
                    labelHelperText: labelHelperText,
                    hideLabel: hideLabel,
                    existingLabels: [...existingLabels]..remove(label),
                    label: label,
                    value: value,
                    onDelete: () async => onDelete().then((_) =>
                        (buildContext.mounted)
                            ? Navigator.of(buildContext).pop()
                            : null),
                    onAddOrSave: (newLabel, newValue,
                            circlesWithSelection) async =>
                        onSave(label, newLabel, newValue, circlesWithSelection)
                            .then((_) => (buildContext.mounted)
                                ? Navigator.of(buildContext).pop()
                                : null)))));

class ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // TODO: This is part of the example in the docs, but is it necessary?
    // Listen to media sharing coming from outside the app while the app is in the memory.
    // _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((files) {
    //   if (files.isNotEmpty) {
    //     final ics = File(files.first.path).readAsStringSync();
    //     if (context.mounted) {
    //       context.goNamed('importIcs', extra: ics);
    //     }
    //   }
    // }, onError: (err) {
    //   debugPrint('getIntentDataStream error: $err');
    // });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        final ics = File(files.first.path).readAsStringSync();
        if (context.mounted) {
          context.goNamed('importIcs', extra: ics);
        }
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  Widget buildProfileScrollView(
          {required ContactDetails contact,
          required Map<String, ContactAddressLocation> addressLocations,
          required Map<String, Uint8List> pictures,
          required Map<String, String> circles,
          required Map<String, List<String>> circleMemberships,
          required ProfileSharingSettings profileSharingSettings,
          required PublicKey? profilePubKey}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 8),
        // NAMES
        ...detailsList(context, contact.names,
            title: Text(context.loc.names.capitalize(),
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            hideLabel: true,
            getDetailSharingSettings: (l) => profileSharingSettings.names[l],
            circles: circles,
            circleMemberships: circleMemberships,
            deleteCallback: (label) async => context
                .read<ProfileCubit>()
                .updateDetails(
                    contact.copyWith(names: {...contact.names}..remove(label))),
            editCallback: (label) async => onEditDetail(
                  context: context,
                  headlineSuffix: context.loc.name,
                  hideLabel: true,
                  label: label,
                  value: contact.names[label] ?? '',
                  circles: circles,
                  circleMemberships: circleMemberships,
                  detailSharingSettings: profileSharingSettings.names,
                  // We don't need to handle label changes here because the id
                  // i.e. label is not exposed for the user to change it
                  onSave: (_, id, value, circlesWithSelection) async => context
                      .read<ProfileCubit>()
                      .updateName(id, value, circlesWithSelection),
                  onDelete: () async => context
                      .read<ProfileCubit>()
                      .updateDetails(contact.copyWith(
                        names: {...contact.names}..remove(label),
                      )),
                ),
            // TODO: Can this also be unified, using the same as other details?
            addCallback: () async => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (buildContext) => DraggableScrollableSheet(
                      expand: false,
                      maxChildSize: 0.9,
                      initialChildSize: 0.9,
                      builder: (_, scrollController) => SingleChildScrollView(
                          controller: scrollController,
                          child: EditOrAddWidget(
                              isEditing: false,
                              hideLabel: true,
                              headlineSuffix: context.loc.name,
                              valueHintText: 'Name (pronouns)',
                              circles: circles
                                  .map((cId, cLabel) => MapEntry(cId, (
                                        cId,
                                        cLabel,
                                        false,
                                        circleMemberships.values
                                            .where((circles) =>
                                                circles.contains(cId))
                                            .length
                                      )))
                                  .values
                                  .toList(),
                              onAddOrSave: (label, name, circles) async =>
                                  context
                                      .read<ProfileCubit>()
                                      .updateName(label, name, circles)
                                      .then((_) => (buildContext.mounted)
                                          ? Navigator.of(buildContext).pop()
                                          : null))),
                    ))),
        // PHONES
        ...detailsList(
          context,
          contact.phones,
          title: Text(context.loc.phones.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) => profileSharingSettings.phones[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (label) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    phones: {...contact.phones}..remove(label),
                  )),
          editCallback: (label) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.phoneNumber,
            labelHelperText: 'e.g. home, mobile or work',
            label: label,
            value: contact.phones[label] ?? '',
            existingLabels: contact.phones.keys.toList(),
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.phones,
            onSave: context.read<ProfileCubit>().updatePhone,
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      phones: {...contact.phones}..remove(label),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.phoneNumber,
              labelHelperText: 'e.g. home, mobile or work',
              defaultLabel: (contact.phones.isEmpty) ? 'mobile' : null,
              existingLabels: contact.phones.keys.toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circlesWithSelection) async => context
                  .read<ProfileCubit>()
                  .updatePhone(null, label, value, circlesWithSelection)),
        ),
        // E-MAILS
        ...detailsList(
          context,
          contact.emails,
          title: Text(context.loc.emails.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) => profileSharingSettings.emails[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (label) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    emails: {...contact.emails}..remove(label),
                  )),
          editCallback: (label) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.emailAddress,
            labelHelperText: 'e.g. private or work',
            label: label,
            existingLabels: contact.emails.keys.toList(),
            value: contact.emails[label] ?? '',
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.emails,
            onSave: context.read<ProfileCubit>().updateEmail,
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      emails: {...contact.emails}..remove(label),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.emailAddress,
              labelHelperText: 'e.g. private or work',
              defaultLabel: (contact.emails.isEmpty) ? 'private' : null,
              existingLabels: contact.emails.keys.toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circlesWithSelection) async => context
                  .read<ProfileCubit>()
                  .updateEmail(null, label, value, circlesWithSelection)),
        ),
        // ADDRESSES
        ...detailsList(
            context,
            addressLocations.map((label, address) =>
                MapEntry(label, commasToNewlines(address.address ?? ''))),
            title: Text(context.loc.addresses.capitalize(),
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            getDetailSharingSettings: (l) =>
                profileSharingSettings.addresses[l],
            circles: circles,
            circleMemberships: circleMemberships,
            deleteCallback: (label) async => context
                .read<ProfileCubit>()
                .updateAddressLocations({...addressLocations}..remove(label)),
            editCallback: (label) async => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (buildContext) => DraggableScrollableSheet(
                    expand: false,
                    maxChildSize: 0.9,
                    initialChildSize: 0.9,
                    builder: (_, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: EditOrAddAddressWidget(
                            isEditing: true,
                            circles: circles
                                .map((cId, cLabel) => MapEntry(cId, (
                                      cId,
                                      cLabel,
                                      profileSharingSettings.addresses[label]
                                              ?.contains(cId) ??
                                          false,
                                      circleMemberships.values
                                          .where((circles) =>
                                              circles.contains(cId))
                                          .length
                                    )))
                                .values
                                .toList(),
                            headlineSuffix: context.loc.address,
                            labelHelperText: 'e.g. home or cabin',
                            existingLabels: addressLocations.keys.toList()
                              ..remove(label),
                            label: label,
                            value: addressLocations[label],
                            onDelete: () async {
                              await context
                                  .read<ProfileCubit>()
                                  .updateAddressLocations(
                                      {...addressLocations}..remove(label));
                              if (buildContext.mounted) {
                                Navigator.of(buildContext).pop();
                              }
                            },
                            onAddOrSave: (oldLabel, label, value,
                                circlesWithSelection) async {
                              await context
                                  .read<ProfileCubit>()
                                  .updateAddressLocation(oldLabel, label, value,
                                      circlesWithSelection);
                              if (buildContext.mounted) {
                                Navigator.of(buildContext).pop();
                              }
                            })))),
            addCallback: () async => showModalBottomSheet<void>(
                context: context,
                isDismissible: true,
                isScrollControlled: true,
                builder: (buildContext) => DraggableScrollableSheet(
                    expand: false,
                    maxChildSize: 0.9,
                    initialChildSize: 0.9,
                    builder: (_, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: EditOrAddAddressWidget(
                          isEditing: false,
                          circles: circles
                              .map((cId, cLabel) => MapEntry(cId, (
                                    cId,
                                    cLabel,
                                    false,
                                    circleMemberships.values
                                        .where(
                                            (circles) => circles.contains(cId))
                                        .length
                                  )))
                              .values
                              .toList(),
                          headlineSuffix: context.loc.address,
                          valueHintText: 'Street, City, Country',
                          labelHelperText: 'e.g. home or cabin',
                          label: (addressLocations.isEmpty) ? 'home' : null,
                          existingLabels: addressLocations.keys.toList(),
                          onAddOrSave: (oldLabel, label, value,
                              circlesWithSelection) async {
                            await context
                                .read<ProfileCubit>()
                                .updateAddressLocation(oldLabel, label, value,
                                    circlesWithSelection);
                            if (buildContext.mounted) {
                              Navigator.of(buildContext).pop();
                            }
                          },
                        ))))),
        // SOCIAL MEDIAS
        ...detailsList(
          context,
          contact.socialMedias,
          title: Text('Socials',
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              profileSharingSettings.socialMedias[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (label) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    socialMedias: {...contact.socialMedias}..remove(label),
                  )),
          editCallback: (label) async => onEditDetail(
            context: context,
            headlineSuffix: 'social media profile',
            labelHelperText: 'e.g. Signal or Instagram',
            existingLabels: contact.socialMedias.keys.toList(),
            label: label,
            value: contact.socialMedias[label] ?? '',
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.socialMedias,
            onSave: context.read<ProfileCubit>().updateSocialMedia,
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      socialMedias: {...contact.socialMedias}..remove(label),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'social media profile',
              valueHintText: '@profileName',
              labelHelperText: 'e.g. Signal or Instagram',
              existingLabels: contact.socialMedias.keys.toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circlesWithSelection) async => context
                  .read<ProfileCubit>()
                  .updateSocialMedia(null, label, value, circlesWithSelection)),
        ),
        // WEBSITES
        ...detailsList(
          context,
          contact.websites,
          title: Text(context.loc.websites.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) => profileSharingSettings.websites[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (label) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    websites: {...contact.websites}..remove(label),
                  )),
          editCallback: (label) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.website,
            labelHelperText: 'e.g. blog or portfolio',
            label: label,
            existingLabels: contact.websites.keys.toList(),
            value: contact.websites[label] ?? '',
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.websites,
            onSave: context.read<ProfileCubit>().updateWebsite,
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      websites: {...contact.websites}..remove(label),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.website,
              defaultLabel: (contact.websites.isEmpty) ? 'website' : null,
              // labelHelperText: 'e.g. blog or portfolio',
              valueHintText: 'my-awesome-site.com',
              existingLabels: contact.websites.keys.toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circlesWithSelection) async => context
                  .read<ProfileCubit>()
                  .updateWebsite(null, label, value, circlesWithSelection)),
        ),
        // EVENTS
        ...detailsList(
            context,
            contact.events.map((label, date) => MapEntry(
                label,
                DateFormat.yMd(Localizations.localeOf(context).languageCode)
                    .format(date))),
            title: Text('Dates',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            getDetailSharingSettings: (l) => profileSharingSettings.events[l],
            circles: circles,
            circleMemberships: circleMemberships,
            deleteCallback: (label) async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      events: {...contact.events}..remove(label),
                    )),
            editCallback: (label) async => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (buildContext) => DraggableScrollableSheet(
                    expand: false,
                    maxChildSize: 0.9,
                    initialChildSize: 0.9,
                    builder: (_, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: EditOrAddEventWidget(
                            isEditing: true,
                            circles: circles
                                .map((cId, cLabel) => MapEntry(cId, (
                                      cId,
                                      cLabel,
                                      profileSharingSettings.events[label]
                                              ?.contains(cId) ??
                                          false,
                                      circleMemberships.values
                                          .where((circles) =>
                                              circles.contains(cId))
                                          .length
                                    )))
                                .values
                                .toList(),
                            headlineSuffix: 'date',
                            existingLabels: [...contact.events.keys]
                              ..remove(label),
                            label: label,
                            value: (contact.events.containsKey(label))
                                ? DateFormat('yyyy-MM-dd')
                                    .format(contact.events[label]!)
                                : null,
                            onDelete: () async {
                              await context
                                  .read<ProfileCubit>()
                                  .updateDetails(contact.copyWith(
                                    events: {...contact.events}..remove(label),
                                  ));
                              if (buildContext.mounted) {
                                Navigator.of(buildContext).pop();
                              }
                            },
                            onAddOrSave: (oldLabel, label, value,
                                circlesWithSelection) async {
                              await context.read<ProfileCubit>().updateEvent(
                                  oldLabel, label, value, circlesWithSelection);
                              if (buildContext.mounted) {
                                Navigator.of(buildContext).pop();
                              }
                            })))),
            addCallback: () async => showModalBottomSheet<void>(
                context: context,
                isDismissible: true,
                isScrollControlled: true,
                builder: (buildContext) => DraggableScrollableSheet(
                    expand: false,
                    maxChildSize: 0.9,
                    initialChildSize: 0.9,
                    builder: (_, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: EditOrAddEventWidget(
                          isEditing: false,
                          circles: circles
                              .map((cId, cLabel) => MapEntry(cId, (
                                    cId,
                                    cLabel,
                                    false,
                                    circleMemberships.values
                                        .where(
                                            (circles) => circles.contains(cId))
                                        .length
                                  )))
                              .values
                              .toList(),
                          headlineSuffix: 'date',
                          valueHintText: 'YYYY-MM-DD',
                          label: (contact.events.isEmpty) ? 'birthday' : null,
                          existingLabels: contact.events.keys.toList(),
                          onAddOrSave: (oldLabel, label, value,
                              circlesWithSelection) async {
                            await context.read<ProfileCubit>().updateEvent(
                                oldLabel, label, value, circlesWithSelection);
                            if (buildContext.mounted) {
                              Navigator.of(buildContext).pop();
                            }
                          },
                        ))))),
        // PICTURES / AVATARS
        CirclesWithAvatarWidget(
          pictures: pictures,
          title: Text(context.loc.pictures.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          // TODO: We dont need avatar sharing settings anymore at all, do we?
          //  profileSharingSettings.avatars,
          circles: circles,
          circleMemberCount: Map.fromEntries(circles.keys.map((circleId) =>
              MapEntry(
                  circleId,
                  circleMemberships.values
                      .where((ids) => ids.contains(circleId))
                      .length))),
          editCallback: (circleId, picture) async =>
              context.read<ProfileCubit>().updateAvatar(circleId, picture),
          deleteCallback: context.read<ProfileCubit>().removeAvatar,
        ),

        // TODO: Do one of these per name and include the name? or allow customizing the name?
        // TODO: Also feature this as an option on the create invite page?
        if (profilePubKey != null)
          ..._card(
              title: Text('Public invite link',
                  textScaler: const TextScaler.linear(1.4),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              children: [
                const SizedBox(height: 10),
                const Text(
                    'You can add the following link to your social media '
                    'profiles, website, e-mail signature or any place where '
                    'you want to show others an opportunity to connect with '
                    'you via Coagulate. Others can use this link to generate a '
                    'personal sharing offer for you that they can send you '
                    'through existing means of communication for you to add '
                    'them to Coagulate.'),
                Row(children: [
                  Expanded(
                      child: Text(
                          profileUrl(contact.names.values.firstOrNull ?? '???',
                                  profilePubKey)
                              .toString(),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)),
                  IconButton.filledTonal(
                      onPressed: () async => SharePlus.instance.share(
                          ShareParams(
                              uri: profileUrl(
                                  contact.names.values.firstOrNull ?? '???',
                                  profilePubKey))),
                      icon: const Icon(Icons.copy)),
                ]),
              ]),
      ]);

  Widget _scaffoldBody(ProfileState state) => (state.profileInfo == null)
      ? const Center(child: CircularProgressIndicator())
      : CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: buildProfileScrollView(
              contact: state.profileInfo!.details,
              pictures: state.profileInfo!.pictures
                  .map((k, v) => MapEntry(k, Uint8List.fromList(v))),
              addressLocations: state.profileInfo!.addressLocations,
              circles: state.circles,
              circleMemberships: state.circleMemberships,
              profileSharingSettings: state.profileInfo!.sharingSettings,
              profilePubKey: state.profileInfo!.mainKeyPair?.key,
            ),
          )
        ]);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text(context.loc.profileHeadline)),
              body: _scaffoldBody(state)));
}
