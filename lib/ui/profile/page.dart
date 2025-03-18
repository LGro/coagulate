// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_sharing_settings.dart';
import '../../data/repositories/contacts.dart';
import '../utils.dart';
import '../widgets/address_coordinates_form.dart';
import 'cubit.dart';

class Name extends Equatable {
  const Name({required this.name, required this.label});

  final String name;
  final String label;
  @override
  List<Object?> get props => [name, label];
}

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
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                (widget.isEditing)
                    ? context.loc.profileEditHeadline(widget.headlineSuffix)
                    : context.loc.profileAddHeadline(widget.headlineSuffix),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.onDelete != null)
                IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_forever, color: Colors.red)),
            ]),
            const SizedBox(height: 8),
            if (!widget.hideLabel) ...[
              const SizedBox(height: 8),
              FractionallySizedBox(
                  widthFactor: 0.5,
                  child: TextFormField(
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
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _label = label;
                        });
                      }
                    },
                  )),
              const SizedBox(height: 8),
            ],
            TextFormField(
              initialValue: _value,
              autocorrect: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.valueHintText ?? widget.headlineSuffix,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a value.';
                }
                return null;
              },
              onChanged: (value) {
                if (_formKey.currentState!.validate()) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(context.loc.cancel.capitalize()),
                ),
                FilledButton(
                  onPressed: () => (_formKey.currentState!.validate())
                      ? widget.onAddOrSave(
                          (_label ?? '').trim(),
                          (_value ?? '').trim(),
                          _circles.map((e) => (e.$1, e.$2, e.$3)).toList())
                      : null,
                  child: Text((widget.isEditing)
                      ? context.loc.save.capitalize()
                      : context.loc.add.capitalize()),
                ),
              ],
            ),
          ],
        ),
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

List<Widget> detailsList<T>(
  BuildContext context,
  List<T> details, {
  required String Function(T detail) getValue,
  required String Function(T detail) getLabel,
  Text? title,
  Map<String, String>? circles,
  Map<String, List<String>>? circleMemberships,
  List<String>? Function(String label)? getDetailSharingSettings,
  void Function(int i)? editCallback,
  VoidCallback? addCallback,
  void Function(int i)? deleteCallback,
  bool hideLabel = false,
  bool hideEditButton = false,
}) =>
    _card(
        title: title,
        children: details
                .asMap()
                .map((i, e) {
                  final label = getLabel(e);

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

                  return MapEntry<int, Widget>(
                    i,
                    Dismissible(
                      key: Key('$title|${getValue(e)}|$i'),
                      direction: (deleteCallback != null)
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      onDismissed: (deleteCallback != null)
                          ? (_) => deleteCallback(i)
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
                            : () => editCallback(i),
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
                                      Text(getLabel(e),
                                          textScaler:
                                              const TextScaler.linear(1.1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                    Text(getValue(e),
                                        textScaler:
                                            const TextScaler.linear(1.1),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
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
                                    onPressed: () => editCallback(i),
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

String _commaToNewline(String s) =>
    s.replaceAll(', ', ',').replaceAll(',', '\n');

/// Potentially custom label for fields like email, phone, website
Text _label(String name, String customLabel) =>
    Text((name != 'custom') ? name : customLabel,
        style: const TextStyle(fontSize: 16));

bool labelDoesMatch(String name, Address address) {
  if (address.label == AddressLabel.custom) {
    return name == address.customLabel;
  }
  return name == address.label.name;
}

List<Widget> addressesWithForms(BuildContext context, List<Address> addresses,
        List<ContactAddressLocation> locations,
        {void Function(int index, String label)? editCirclesCallback,
        void Function(String value)? editCallback,
        VoidCallback? addCallback}) =>
    _card(
        title: Text(context.loc.addresses.capitalize(),
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
        children: addresses
            .asMap()
            .map((i, e) => MapEntry(
                i,
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _label(e.label.name, e.customLabel),
                          Text(_commaToNewline(e.address),
                              style: const TextStyle(fontSize: 19)),
                        ])),
                    if (editCirclesCallback != null)
                      IconButton(
                          key: Key('addressesCirclesMgmt${i}'),
                          onPressed: () => editCirclesCallback(
                              i, _label(e.label.name, e.customLabel).data!),
                          icon: const Icon(Icons.edit)),
                  ]),
                  if (locations
                      .where((l) => labelDoesMatch(l.name, e))
                      .isEmpty) ...[
                    const SizedBox(height: 8),
                    AddressCoordinatesForm(
                        i: i,
                        longitude: locations
                            .where((l) => labelDoesMatch(l.name, e))
                            .firstOrNull
                            ?.longitude,
                        latitude: locations
                            .where((l) => labelDoesMatch(l.name, e))
                            .firstOrNull
                            ?.latitude,
                        callback: (lng, lat) => context
                            .read<ProfileCubit>()
                            .updateCoordinates(i, lng, lat)),
                    // TODO: Add small map previewing the location when coordinates are available
                    TextButton(
                        child: const Text('Auto Fetch Coordinates'),
                        // TODO: Switch to address index instead of label? Can there be duplicates?
                        onPressed: () async => showDialog<void>(
                            context: context,
                            // barrierDismissible: false,
                            builder: (dialogContext) =>
                                _confirmPrivacyLeakDialog(
                                    dialogContext,
                                    e.address,
                                    () => unawaited(context
                                        .read<ProfileCubit>()
                                        .fetchCoordinates(i))))),
                  ]
                ])))
            .values
            .asList());

AlertDialog _confirmPrivacyLeakDialog(
        BuildContext context, String address, void Function() addressLookup) =>
    AlertDialog(
        title: const Text('Potential Privacy Leak'),
        content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
          Text('Looking up the coordinates of "$address" automatically '
              'only works by sending that address to '
              '${(Platform.isIOS) ? 'Apple' : 'Google'}. '
              'Are you ok with leaking to them that you relate to this '
              'address somehow?'),
        ])),
        actions: <Widget>[
          // TODO: Store choice and don't ask again
          // Row(mainAxisSize: MainAxisSize.min, children: [
          //   Checkbox(value: false, onChanged: (v) => {}),
          //   const Text('remember')
          // ]),
          TextButton(
              child: const Text('Approve'),
              onPressed: () async {
                addressLookup();
                Navigator.of(context).pop();
              }),
          TextButton(
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              })
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
  required Future<void> Function(String label, String number,
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
                    onAddOrSave: (label, value, circlesWithSelection) async =>
                        onSave(label, value, circlesWithSelection).then((_) =>
                            (buildContext.mounted)
                                ? Navigator.of(buildContext).pop()
                                : null)))));

class ProfileViewState extends State<ProfileView> {
  Widget buildProfileScrollView(
          {required ContactDetails contact,
          required List<ContactAddressLocation> addressLocations,
          required Map<String, Uint8List> pictures,
          required Map<String, String> circles,
          required Map<String, List<String>> circleMemberships,
          required ProfileSharingSettings profileSharingSettings}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 8),
        // NAMES
        ...detailsList<Name>(
            context,
            contact.names.entries
                .map((e) => Name(name: e.value, label: e.key))
                .toList(),
            title: Text(context.loc.names.capitalize(),
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            getValue: (v) => v.name,
            getLabel: (v) => v.label,
            hideLabel: true,
            getDetailSharingSettings: (l) => profileSharingSettings.names[l],
            circles: circles,
            circleMemberships: circleMemberships,
            deleteCallback: (i) async => context
                .read<ProfileCubit>()
                .updateDetails(contact.copyWith(
                  names:
                      Map.fromEntries([...contact.names.entries]..removeAt(i)),
                )),
            editCallback: (i) async => onEditDetail(
                  context: context,
                  headlineSuffix: context.loc.name,
                  hideLabel: true,
                  label: contact.names.entries.elementAt(i).key,
                  value: contact.names.entries.elementAt(i).value,
                  circles: circles,
                  circleMemberships: circleMemberships,
                  detailSharingSettings: profileSharingSettings.names,
                  onSave: (id, name, circlesWithSelection) async => context
                      .read<ProfileCubit>()
                      .updateName(name, circlesWithSelection, id: id),
                  onDelete: () async => context
                      .read<ProfileCubit>()
                      .updateDetails(contact.copyWith(
                        names: Map.fromEntries(
                            [...contact.names.entries]..removeAt(i)),
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
                              onAddOrSave: (_, name, circles) async => context
                                  .read<ProfileCubit>()
                                  .updateName(name, circles)
                                  .then((_) => (buildContext.mounted)
                                      ? Navigator.of(buildContext).pop()
                                      : null))),
                    ))),
        // PHONES
        ...detailsList<Phone>(
          context,
          contact.phones,
          title: Text(context.loc.phones.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
          getDetailSharingSettings: (l) => profileSharingSettings.phones[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (i) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    phones: [...contact.phones]..removeAt(i),
                  )),
          editCallback: (i) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.phoneNumber,
            labelHelperText: 'e.g. home, mobile or work',
            label: (contact.phones[i].label.name != 'custom')
                ? contact.phones[i].label.name
                : contact.phones[i].customLabel,
            value: contact.phones[i].number,
            existingLabels: contact.phones
                .map((v) =>
                    (v.label.name != 'custom') ? v.label.name : v.customLabel)
                .toList(),
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.phones,
            onSave: (label, value, circlesWithSelection) async => context
                .read<ProfileCubit>()
                .updatePhone(
                    Phone(value, label: PhoneLabel.custom, customLabel: label),
                    circlesWithSelection,
                    i: i),
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      phones: [...contact.phones]..removeAt(i),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.phoneNumber,
              labelHelperText: 'e.g. home, mobile or work',
              defaultLabel: (contact.phones.isEmpty) ? 'mobile' : null,
              existingLabels: contact.phones
                  .map((v) =>
                      (v.label.name != 'custom') ? v.label.name : v.customLabel)
                  .toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .updatePhone(
                      Phone(value,
                          label: PhoneLabel.custom, customLabel: label),
                      circles)),
        ),
        // E-MAILS
        ...detailsList<Email>(
          context,
          contact.emails,
          title: Text(context.loc.emails.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
          getDetailSharingSettings: (l) => profileSharingSettings.emails[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (i) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    emails: [...contact.emails]..removeAt(i),
                  )),
          editCallback: (i) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.emailAddress,
            labelHelperText: 'e.g. private or work',
            label: (contact.emails[i].label.name != 'custom')
                ? contact.emails[i].label.name
                : contact.emails[i].customLabel,
            existingLabels: contact.emails
                .map((v) =>
                    (v.label.name != 'custom') ? v.label.name : v.customLabel)
                .toList(),
            value: contact.emails[i].address,
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.emails,
            onSave: (label, value, circlesWithSelection) async => context
                .read<ProfileCubit>()
                .updateEmail(
                    Email(value, label: EmailLabel.custom, customLabel: label),
                    circlesWithSelection,
                    i: i),
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      emails: [...contact.emails]..removeAt(i),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.emailAddress,
              labelHelperText: 'e.g. private or work',
              defaultLabel: (contact.emails.isEmpty) ? 'private' : null,
              existingLabels: contact.emails
                  .map((v) =>
                      (v.label.name != 'custom') ? v.label.name : v.customLabel)
                  .toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .updateEmail(
                      Email(value,
                          label: EmailLabel.custom, customLabel: label),
                      circles)),
        ),
        // ADDRESSES
        //addressLocations
        ...detailsList<Address>(
          context,
          contact.addresses,
          title: Text(context.loc.addresses.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => _commaToNewline(v.address),
          getDetailSharingSettings: (l) => profileSharingSettings.addresses[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (i) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    addresses: [...contact.addresses]..removeAt(i),
                  )),
          editCallback: (i) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.address,
            labelHelperText: 'e.g. home or cabin',
            label: (contact.addresses[i].label.name != 'custom')
                ? contact.addresses[i].label.name
                : contact.addresses[i].customLabel,
            existingLabels: contact.addresses
                .map((v) =>
                    (v.label.name != 'custom') ? v.label.name : v.customLabel)
                .toList(),
            value: contact.addresses[i].address,
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.addresses,
            onSave: (label, value, circlesWithSelection) async => context
                .read<ProfileCubit>()
                .updateAddress(
                    Address(value,
                        label: AddressLabel.custom, customLabel: label),
                    circlesWithSelection,
                    i: i),
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      addresses: [...contact.addresses]..removeAt(i),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.address,
              defaultLabel: (contact.addresses.isEmpty) ? 'home' : null,
              valueHintText: 'Street, City, Country',
              labelHelperText: 'e.g. home or cabin',
              existingLabels: contact.addresses
                  .map((v) =>
                      (v.label.name != 'custom') ? v.label.name : v.customLabel)
                  .toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .updateAddress(
                      Address(value,
                          label: AddressLabel.custom, customLabel: label),
                      circles)),
        ),
        // SOCIAL MEDIAS
        ...detailsList<SocialMedia>(
          context,
          contact.socialMedias,
          title: Text('Socials',
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
          getDetailSharingSettings: (l) =>
              profileSharingSettings.socialMedias[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (i) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    socialMedias: [...contact.socialMedias]..removeAt(i),
                  )),
          editCallback: (i) async => onEditDetail(
            context: context,
            headlineSuffix: 'social media profile',
            labelHelperText: 'e.g. Signal or Instagram',
            label: (contact.socialMedias[i].label.name != 'custom')
                ? contact.socialMedias[i].label.name
                : contact.socialMedias[i].customLabel,
            existingLabels: contact.socialMedias
                .map((v) =>
                    (v.label.name != 'custom') ? v.label.name : v.customLabel)
                .toList(),
            value: contact.socialMedias[i].userName,
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.socialMedias,
            onSave: (label, value, circlesWithSelection) async => context
                .read<ProfileCubit>()
                .updateSocialMedia(
                    SocialMedia(value,
                        label: SocialMediaLabel.custom, customLabel: label),
                    circlesWithSelection,
                    i: i),
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      socialMedias: [...contact.socialMedias]..removeAt(i),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'social media profile',
              valueHintText: '@profileName',
              labelHelperText: 'e.g. Signal or Instagram',
              existingLabels: contact.socialMedias
                  .map((v) =>
                      (v.label.name != 'custom') ? v.label.name : v.customLabel)
                  .toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .updateSocialMedia(
                      SocialMedia(value,
                          label: SocialMediaLabel.custom, customLabel: label),
                      circles)),
        ),
        // WEBSITES
        ...detailsList<Website>(
          context,
          contact.websites,
          title: Text(context.loc.websites.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
          getDetailSharingSettings: (l) => profileSharingSettings.websites[l],
          circles: circles,
          circleMemberships: circleMemberships,
          deleteCallback: (i) async =>
              context.read<ProfileCubit>().updateDetails(contact.copyWith(
                    websites: [...contact.websites]..removeAt(i),
                  )),
          editCallback: (i) async => onEditDetail(
            context: context,
            headlineSuffix: context.loc.website,
            labelHelperText: 'e.g. blog or portfolio',
            label: (contact.websites[i].label.name != 'custom')
                ? contact.websites[i].label.name
                : contact.websites[i].customLabel,
            existingLabels: contact.websites
                .map((v) =>
                    (v.label.name != 'custom') ? v.label.name : v.customLabel)
                .toList(),
            value: contact.websites[i].url,
            circles: circles,
            circleMemberships: circleMemberships,
            detailSharingSettings: profileSharingSettings.websites,
            onSave: (label, value, circlesWithSelection) async => context
                .read<ProfileCubit>()
                .updateWebsite(
                    Website(value,
                        label: WebsiteLabel.custom, customLabel: label),
                    circlesWithSelection,
                    i: i),
            onDelete: () async =>
                context.read<ProfileCubit>().updateDetails(contact.copyWith(
                      websites: [...contact.websites]..removeAt(i),
                    )),
          ),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: context.loc.website,
              defaultLabel: (contact.websites.isEmpty) ? 'website' : null,
              // labelHelperText: 'e.g. blog or portfolio',
              valueHintText: 'my-awesome-site.com',
              existingLabels: contact.websites
                  .map((v) =>
                      (v.label.name != 'custom') ? v.label.name : v.customLabel)
                  .toList(),
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .updateWebsite(
                      Website(value,
                          label: WebsiteLabel.custom, customLabel: label),
                      circles)),
        ),
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

        // TODO: Do one of these per name and include the name?
        // TODO: Also feature this as an option on the create invite page?
        // _card(
        //     Text('Public invite link',
        //         textScaler: const TextScaler.linear(1.4),
        //         style: TextStyle(
        //             fontWeight: FontWeight.bold,
        //             color: Theme.of(context).colorScheme.primary)),
        //     [
        //       const SizedBox(height: 4),
        //       const Text('You can add the following link to your social media '
        //           'profiles, website, e-mail signature or any place where you '
        //           'want to show others an opportunity to connect with you via '
        //           'Coagulate. Others can use this link to generate a personal '
        //           'sharing offer for you that they can send you through '
        //           'existing means of communication.'),
        //       Row(children: [
        //         const Text('https://coagulate.social/c/#PUBKEY'),
        //         IconButton(
        //             onPressed: () async =>
        //                 Share.share('https://coagulate.social/c/#PUBKEY'),
        //             icon: const Icon(Icons.copy)),
        //       ]),
        //     ]),
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
                addressLocations:
                    state.profileInfo!.addressLocations.values.asList(),
                circles: state.circles,
                circleMemberships: state.circleMemberships,
                profileSharingSettings: state.profileInfo!.sharingSettings),
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
