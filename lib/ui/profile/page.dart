// Copyright 2024 The Coagulate Authors. All rights reserved.
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
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_sharing_settings.dart';
import '../../data/repositories/contacts.dart';
import '../widgets/address_coordinates_form.dart';
import 'cubit.dart';

class Name extends Equatable {
  const Name({required this.name, required this.label});

  final String name;
  final String label;
  @override
  List<Object?> get props => [name, label];
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
  Widget build(BuildContext context) => _card(
      widget.title,
      widget.circles
              .map((circleId, circleLabel) => MapEntry<String, Widget>(
                  circleId,
                  Dismissible(
                      key: Key('avatar|$circleId'),
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
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            try {
                              final pickedFile = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 90,
                              );
                              if (context.mounted && pickedFile != null) {
                                final p = await pickedFile.readAsBytes();
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
                              }
                            } catch (e) {
                              // TODO: Handle
                              print(e);
                            }
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(children: [
                                if (!_pictures.containsKey(circleId))
                                  const CircleAvatar(
                                      radius: 48, child: Icon(Icons.person)),
                                if (_pictures.containsKey(circleId))
                                  CircleAvatar(
                                    backgroundImage:
                                        MemoryImage(_pictures[circleId]!),
                                    radius: 48,
                                  ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    //FIXME: Overflow / wrapping for long circle names
                                    child: Expanded(
                                        child: Text(
                                            '$circleLabel (${widget.circleMemberCount[circleId] ?? 0} '
                                            'contact${(widget.circleMemberCount[circleId] == 1) ? '' : 's'})',
                                            softWrap: true))),
                              ]))))))
              .values
              .asList() +
          [
            const SizedBox(height: 8),
            const Text('You can set one picture per circle. Contacts that '
                'belong to several circles that have a picture will see the '
                'one picture belonging to the smallest circle.'),
            const SizedBox(height: 4),
          ]);
}

// TODO: Pass other labels to prevent duplicates
class EditOrAddWidget extends StatefulWidget {
  const EditOrAddWidget({
    super.key,
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    required this.valueController,
    this.onDelete,
    this.labelController,
    this.labelHelperText,
    this.hideLabel = false,
  });

  final bool isEditing;
  final bool hideLabel;
  final String headlineSuffix;
  final String? labelHelperText;
  final TextEditingController? labelController;
  final TextEditingController valueController;
  final VoidCallback? onDelete;
  final void Function(String label, String value,
      List<(String, String, bool)> selectedCircles) onAddOrSave;
  final List<(String, String, bool, int)> circles;

  @override
  State<EditOrAddWidget> createState() => _EditOrAddWidgetState();
}

class _EditOrAddWidgetState extends State<EditOrAddWidget> {
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  @override
  void initState() {
    super.initState();
    _circles = [...widget.circles];
    _newCircleNameController = TextEditingController();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "${widget.isEditing ? 'Edit' : 'Add'} ${widget.headlineSuffix}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.onDelete != null)
                IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_forever, color: Colors.red)),
            ]),
            const SizedBox(height: 16),
            if (!widget.hideLabel && widget.labelController != null) ...[
              FractionallySizedBox(
                  widthFactor: 0.5,
                  child: TextField(
                    controller: widget.labelController,
                    decoration: InputDecoration(
                      labelText: 'label',
                      isDense: true,
                      helperText: widget.labelHelperText,
                      border: const OutlineInputBorder(),
                    ),
                  )),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: widget.valueController,
              decoration: InputDecoration(
                isDense: true,
                labelText: widget.headlineSuffix,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'and share with circles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // If we don't need wrapping but go for a list, use CheckboxListTile
            Wrap(
              spacing: 8,
              runSpacing: 6,
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
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _newCircleNameController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'new circle',
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: _addNewCircle,
                child: const Text('add'),
              ),
            ]),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Cancel'),
                ),
                // TODO: Give hints that label and text need to be filled out?
                FilledButton(
                  onPressed: () => (widget.valueController.text
                              .trim()
                              .isEmpty ||
                          (!widget.hideLabel &&
                              (widget.labelController?.text.trim().isEmpty ??
                                  false)))
                      ? null
                      : widget.onAddOrSave(
                          widget.labelController?.text.trim() ?? '',
                          widget.valueController.text.trim(),
                          _circles.map((e) => (e.$1, e.$2, e.$3)).toList()),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      );
}

Card _card(Text title, List<Widget> children) => Card(
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[title]),
                  ...children,
                ]))));

Widget detailsList<T>(
  List<T> details, {
  required Text title,
  required String Function(T detail) getValue,
  required String Function(T detail) getLabel,
  Map<String, String>? circles,
  Map<String, List<String>>? circleMemberships,
  List<String>? Function(String label)? getDetailSharingSettings,
  void Function(int i)? editCallback,
  VoidCallback? addCallback,
  void Function(int i)? deleteCallback,
  bool hideLabel = false,
}) =>
    _card(
        title,
        details
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
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: (editCallback == null)
                                  ? null
                                  : () => editCallback(i),
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              if (!hideLabel)
                                                Text(getLabel(e),
                                                    textScaler:
                                                        const TextScaler.linear(
                                                            0.9)),
                                              Text(getValue(e),
                                                  style: const TextStyle(
                                                      fontSize: 19)),
                                              if (circleNames != null &&
                                                  numSharedContacts != null)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4),
                                                    child: Text([
                                                      'Shared with',
                                                      numSharedContacts
                                                          .toString(),
                                                      'contact${(numSharedContacts != 1) ? 's' : ''}',
                                                      if (circleNames
                                                          .isNotEmpty)
                                                        'via circle${(circleNames.length != 1) ? 's' : ''}:',
                                                      circleNames.join(', ')
                                                    ].join(' '))),
                                            ])),
                                        // if (editCallback != null)
                                        //   IconButton.filledTonal(
                                        //       onPressed: () => editCallback(i),
                                        //       icon: const Icon(Icons.edit))
                                      ])))));
                })
                .values
                .asList() +
            [
              if (addCallback != null)
                Center(
                    child: IconButton.filledTonal(
                        onPressed: addCallback, icon: const Icon(Icons.add)))
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

Widget addressesWithForms(BuildContext context, List<Address> addresses,
        List<ContactAddressLocation> locations,
        {void Function(int index, String label)? editCirclesCallback,
        void Function(String value)? editCallback,
        VoidCallback? addCallback}) =>
    _card(
        Text('Addresses',
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
        addresses
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
        String? labelHelperText}) async =>
    showModalBottomSheet<void>(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (buildContext) => DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.3,
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
                    labelHelperText: labelHelperText,
                    labelController: TextEditingController(),
                    valueController: TextEditingController(),
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
  String? labelHelperText,
  bool hideLabel = false,
}) async =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (buildContext) => DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.3,
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
                    labelHelperText: labelHelperText,
                    hideLabel: hideLabel,
                    labelController: TextEditingController(text: label),
                    valueController: TextEditingController(text: value),
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
        detailsList<Name>(
            contact.names.entries
                .map((e) => Name(name: e.value, label: e.key))
                .toList(),
            title: Text('Names',
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
                  headlineSuffix: 'name',
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
                      minChildSize: 0.3,
                      initialChildSize: 0.9,
                      builder: (_, scrollController) => SingleChildScrollView(
                          controller: scrollController,
                          child: EditOrAddWidget(
                              isEditing: false,
                              valueController: TextEditingController(),
                              headlineSuffix: 'name',
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
        detailsList<Phone>(
          contact.phones,
          title: Text('Phones',
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
            headlineSuffix: 'phone number',
            labelHelperText: 'e.g. home, mobile or work',
            label: (contact.phones[i].label.name != 'custom')
                ? contact.phones[i].label.name
                : contact.phones[i].customLabel,
            value: contact.phones[i].number,
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
              headlineSuffix: 'phone number',
              labelHelperText: 'e.g. home, mobile or work',
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
        detailsList<Email>(
          contact.emails,
          title: Text('E-Mails',
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
            headlineSuffix: 'e-mail address',
            labelHelperText: 'e.g. private or work',
            label: (contact.emails[i].label.name != 'custom')
                ? contact.emails[i].label.name
                : contact.emails[i].customLabel,
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
              headlineSuffix: 'e-mail address',
              labelHelperText: 'e.g. private or work',
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
        detailsList<Address>(
          contact.addresses,
          title: Text('Addresses',
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
            headlineSuffix: 'address',
            labelHelperText: 'e.g. home or cabin',
            label: (contact.addresses[i].label.name != 'custom')
                ? contact.addresses[i].label.name
                : contact.addresses[i].customLabel,
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
              headlineSuffix: 'address',
              labelHelperText: 'e.g. home or cabin',
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
        detailsList<SocialMedia>(
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
              labelHelperText: 'e.g. Signal or Instagram',
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
        detailsList<Website>(
          contact.websites,
          title: Text('Websites',
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
            headlineSuffix: 'website',
            labelHelperText: 'e.g. blog or portfolio',
            label: (contact.websites[i].label.name != 'custom')
                ? contact.websites[i].label.name
                : contact.websites[i].customLabel,
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
              headlineSuffix: 'website',
              labelHelperText: 'e.g. blog or portfolio',
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
          title: Text('Pictures',
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

  Widget _scaffoldBody(ProfileState state) => CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: buildProfileScrollView(
              contact: state.profileInfo.details,
              pictures: state.profileInfo.pictures
                  .map((k, v) => MapEntry(k, Uint8List.fromList(v))),
              addressLocations:
                  state.profileInfo.addressLocations.values.asList(),
              circles: state.circles,
              circleMemberships: state.circleMemberships,
              profileSharingSettings: state.profileInfo.sharingSettings),
        )
      ]);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Profile information')),
              body: _scaffoldBody(state)));
}
