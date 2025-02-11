// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_sharing_settings.dart';
import '../../data/repositories/contacts.dart';
import '../widgets/address_coordinates_form.dart';
import '../widgets/circles/cubit.dart';
import '../widgets/circles/widget.dart';
import 'cubit.dart';

class Name extends Equatable {
  const Name({required this.name, required this.label});

  final String name;
  final String label;
  @override
  List<Object?> get props => [name, label];
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
    this.hideLabel = false,
  });

  final bool isEditing;
  final bool hideLabel;
  final String headlineSuffix;
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
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _circles = List.from(widget.circles);
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addNewCircle() {
    if (_titleController.text.isNotEmpty &&
        !_circles.any((e) => e.$2 == _titleController.text)) {
      setState(() {
        _circles.insert(0, (const Uuid().v4(), _titleController.text, true, 0));
      });
      _titleController.clear();
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
                    decoration: const InputDecoration(
                      labelText: 'label',
                      helperText: 'e.g. home or work',
                      border: OutlineInputBorder(),
                    ),
                  )),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: widget.valueController,
              decoration: InputDecoration(
                labelText: widget.headlineSuffix,
                border: OutlineInputBorder(),
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
                              value: _circles[index].$3, onChanged: (_) {}),
                          Text('${_circles[index].$2} (${_circles[index].$4})'),
                          const SizedBox(width: 4),
                        ],
                      ))),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'add circle',
                  border: OutlineInputBorder(),
                ),
              )),
              IconButton(
                onPressed: _addNewCircle,
                icon: const Icon(Icons.add),
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
                FilledButton(
                  onPressed: () => widget.onAddOrSave(
                      widget.labelController?.text ?? '',
                      widget.valueController.text,
                      _circles.map((e) => (e.$1, e.$2, e.$3)).toList()),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      );
}

Future<void> showPickCirclesBottomSheet(
        {required BuildContext context,
        required String value,
        required String label,
        required String coagContactId,
        required List<(String, String, bool, int)> circles,
        required void Function(List<(String, String)> selectedCircles)
            callback}) async =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (modalContext) => Padding(
            padding: EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocProvider(
                      create: (context) => CirclesCubit(
                          context.read<ContactsRepository>(), coagContactId),
                      child: BlocConsumer<CirclesCubit, CirclesState>(
                          listener: (context, state) async {},
                          builder: (context, state) => CirclesForm(
                              customHeader: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, bottom: 12),
                                  child: Row(children: [
                                    const Text('Share "',
                                        textScaler: TextScaler.linear(1.4)),
                                    Flexible(
                                        child: Text(value,
                                            overflow: TextOverflow.ellipsis,
                                            textScaler:
                                                const TextScaler.linear(1.4))),
                                    const Text('" with',
                                        textScaler: TextScaler.linear(1.4)),
                                  ])),
                              allowCreateNew: true,
                              circles: circles,
                              callback: (circles) async => callback(circles
                                  .where((c) => c.$3)
                                  .map((c) => (c.$1, c.$2))
                                  .asList()))))
                ])));

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
            onAdd}) async =>
    showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (buildContext) => FractionallySizedBox(
            heightFactor: 0.9,
            child: DraggableScrollableSheet(
                expand: false,
                maxChildSize: 1,
                minChildSize: 1,
                initialChildSize: 1,
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
                        labelController: TextEditingController(),
                        valueController: TextEditingController(),
                        onAddOrSave:
                            (label, number, circlesWithSelection) async =>
                                onAdd(label, number, circlesWithSelection).then(
                                    (_) => (buildContext.mounted)
                                        ? Navigator.of(buildContext).pop()
                                        : {}))))));

Future<void> onEditDetail({
  required BuildContext context,
  required String headlineSuffix,
  required String label,
  required String value,
  required Map<String, String> circles,
  required Map<String, List<String>> circleMemberships,
  required Map<String, List<String>> detailSharingSettings,
  required int i,
  required Future<void> Function(int i, String label, String number,
          List<(String, String, bool)> circlesWithSelection)
      onSave,
  required Future<void> Function(int i) onDelete,
  bool hideLabel = false,
}) async =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (buildContext) => FractionallySizedBox(
            heightFactor: 0.9,
            child: DraggableScrollableSheet(
                expand: false,
                maxChildSize: 1,
                minChildSize: 1,
                initialChildSize: 1,
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
                        hideLabel: hideLabel,
                        labelController: TextEditingController(text: label),
                        valueController: TextEditingController(text: value),
                        onDelete: () async => onDelete(i).then((_) =>
                            (buildContext.mounted)
                                ? Navigator.of(buildContext).pop()
                                : null),
                        onAddOrSave:
                            (label, value, circlesWithSelection) async =>
                                onSave(i, label, value, circlesWithSelection)
                                    .then((_) => (buildContext.mounted)
                                        ? Navigator.of(buildContext).pop()
                                        : null))))));

class ProfileViewState extends State<ProfileView> {
  Widget buildProfileScrollView(
          {required String coagContactId,
          required ContactDetails contact,
          required List<ContactAddressLocation> addressLocations,
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
                onSave: context.read<ProfileCubit>().editName,
                onDelete: (i) async =>
                    context.read<ProfileCubit>().updateDetails(contact.copyWith(
                          names: Map.fromEntries(
                              [...contact.names.entries]..removeAt(i)),
                        )),
                i: i),
            // TODO: Can this also be unified, using the same as other details?
            addCallback: () async => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                builder: (buildContext) => FractionallySizedBox(
                    heightFactor: 0.9,
                    child: DraggableScrollableSheet(
                      expand: false,
                      maxChildSize: 1,
                      minChildSize: 1,
                      initialChildSize: 1,
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
                                  .addName(name, circles)
                                  .then((_) => (buildContext.mounted)
                                      ? Navigator.of(buildContext).pop()
                                      : null))),
                    )))),
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
              label: (contact.phones[i].label.name != 'custom')
                  ? contact.phones[i].label.name
                  : contact.phones[i].customLabel,
              value: contact.phones[i].number,
              circles: circles,
              circleMemberships: circleMemberships,
              detailSharingSettings: profileSharingSettings.phones,
              onSave: context.read<ProfileCubit>().editPhone,
              onDelete: (i) async =>
                  context.read<ProfileCubit>().updateDetails(contact.copyWith(
                        phones: [...contact.phones]..removeAt(i),
                      )),
              i: i),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'phone number',
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .addPhone(
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
              label: (contact.emails[i].label.name != 'custom')
                  ? contact.emails[i].label.name
                  : contact.emails[i].customLabel,
              value: contact.emails[i].address,
              circles: circles,
              circleMemberships: circleMemberships,
              detailSharingSettings: profileSharingSettings.emails,
              onSave: context.read<ProfileCubit>().editEmail,
              onDelete: (i) async =>
                  context.read<ProfileCubit>().updateDetails(contact.copyWith(
                        emails: [...contact.emails]..removeAt(i),
                      )),
              i: i),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'e-mail address',
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .addEmail(
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
              label: (contact.addresses[i].label.name != 'custom')
                  ? contact.addresses[i].label.name
                  : contact.addresses[i].customLabel,
              value: contact.addresses[i].address,
              circles: circles,
              circleMemberships: circleMemberships,
              detailSharingSettings: profileSharingSettings.addresses,
              onSave: context.read<ProfileCubit>().editAddress,
              onDelete: (i) async =>
                  context.read<ProfileCubit>().updateDetails(contact.copyWith(
                        addresses: [...contact.addresses]..removeAt(i),
                      )),
              i: i),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'address',
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .addAddress(
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
              label: (contact.socialMedias[i].label.name != 'custom')
                  ? contact.socialMedias[i].label.name
                  : contact.socialMedias[i].customLabel,
              value: contact.socialMedias[i].userName,
              circles: circles,
              circleMemberships: circleMemberships,
              detailSharingSettings: profileSharingSettings.socialMedias,
              onSave: context.read<ProfileCubit>().editSocialMedia,
              onDelete: (i) async =>
                  context.read<ProfileCubit>().updateDetails(contact.copyWith(
                        socialMedias: [...contact.socialMedias]..removeAt(i),
                      )),
              i: i),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'social media profile',
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .addSocialMedia(
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
              label: (contact.websites[i].label.name != 'custom')
                  ? contact.websites[i].label.name
                  : contact.websites[i].customLabel,
              value: contact.websites[i].url,
              circles: circles,
              circleMemberships: circleMemberships,
              detailSharingSettings: profileSharingSettings.websites,
              onSave: context.read<ProfileCubit>().editWebsite,
              onDelete: (i) async =>
                  context.read<ProfileCubit>().updateDetails(contact.copyWith(
                        websites: [...contact.websites]..removeAt(i),
                      )),
              i: i),
          addCallback: () async => onAddDetail(
              context: context,
              headlineSuffix: 'website',
              circles: circles,
              circleMemberships: circleMemberships,
              onAdd: (label, value, circles) async => context
                  .read<ProfileCubit>()
                  .addWebsite(
                      Website(value,
                          label: WebsiteLabel.custom, customLabel: label),
                      circles)),
        ),
        // PICTURES / AVATARS
        _card(
            Text('Avatars',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            [const Text('Profile picture support is coming soon :)')])
      ]);

  Widget _scaffoldBody(ProfileState state) => (state.profileContact == null)
      ? const Center(child: CircularProgressIndicator())
      : CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: buildProfileScrollView(
                coagContactId: state.profileContact!.coagContactId,
                contact: state.profileContact!.details!,
                addressLocations:
                    state.profileContact!.addressLocations.values.asList(),
                circles: state.circles,
                circleMemberships: state.circleMemberships,
                profileSharingSettings: state.sharingSettings!),
          )
        ]);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('My information')),
              body: _scaffoldBody(state)));
}
