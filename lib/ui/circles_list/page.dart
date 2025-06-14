// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/repositories/contacts.dart';
import '../circle_details/page.dart';
import '../utils.dart';
import 'cubit.dart';

int crossAxisCountFromNumPictures(int numPictures) {
  if (numPictures <= 1) {
    return 1;
  }
  if (numPictures <= 7) {
    return 2;
  }
  // TODO: Add more steps for larger number of pictures available?
  return 3;
}

class _GridCircleItem extends StatelessWidget {
  const _GridCircleItem(this.circleName, this.numCircleMembers,
      {this.pictures = const []});

  final String circleName;
  final int numCircleMembers;
  final Iterable<Uint8List> pictures;

  @override
  Widget build(BuildContext context) {
    // Force nulls for unavailable pictures to filter them out instead of
    // rendering placeholders
    final images = pictures
        .map((p) =>
            (p.isEmpty) ? null : roundPictureOrPlaceholder(p, clipOval: false))
        .whereType<Image>()
        .toList();
    final image = Semantics(
      label: '$circleName\n$numCircleMembers members',
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surfaceBright,
        child: (images.isEmpty)
            ? const Icon(Icons.group, size: 42)
            : StaggeredGrid.count(
                crossAxisCount: crossAxisCountFromNumPictures(images.length),
                children: images,
              ),
      ),
    );

    return GridTile(
        footer: Material(
          color: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GridTileBar(
            backgroundColor: Colors.black45,
            title: Expanded(
                child: Padding(
                    padding: const EdgeInsetsGeometry.only(top: 16),
                    child: Text(circleName, overflow: TextOverflow.ellipsis))),
            subtitle: Expanded(
                child: Padding(
                    padding: const EdgeInsetsGeometry.only(bottom: 8),
                    child: Text('$numCircleMembers members',
                        overflow: TextOverflow.ellipsis))),
          ),
        ),
        child: image);
  }
}

class CirclesListPage extends StatefulWidget {
  const CirclesListPage({super.key});

  @override
  _CirclesListPageState createState() => _CirclesListPageState();
}

class _CirclesListPageState extends State<CirclesListPage> {
  final _formKey = GlobalKey<FormState>();
  String _newCircleName = '';
  late final TextEditingController _newCircleController;

  /// Randomness for re-opening the page but consistency across re-paints
  int? _sessionSeed;

  @override
  void initState() {
    super.initState();
    _sessionSeed = Random().nextInt(1 << 32);
    _newCircleController = TextEditingController()
      ..addListener(_onNewCircleNameChanges);
  }

  void _onNewCircleNameChanges() {
    setState(() {
      _newCircleName = _newCircleController.text;
    });
  }

  void _resetState() {
    _newCircleController.text = '';
    setState(() {
      _newCircleName = '';
    });
  }

  Widget _circlesGrid(BuildContext context, Map<String, String> circles,
          Map<String, List<String>> circleMemberships) =>
      GridView.count(
        restorationId: 'circles_grid_view',
        crossAxisCount: (MediaQuery.of(context).size.width >
                MediaQuery.of(context).size.height)
            ? 5
            : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        childAspectRatio: 1,
        children: (circles.entries.toList()
              ..sortBy((c) => c.value.toLowerCase()))
            .map<Widget>((circle) => GestureDetector(
                onTap: () async => Navigator.of(context)
                    .push(CircleDetailsPage.route(circle.key)),
                child: _GridCircleItem(
                  circle.value,
                  circleMemberships.values
                      .where((cIds) => cIds.contains(circle.key))
                      .length,
                  pictures: context
                      .read<CirclesListCubit>()
                      .contactsRepository
                      .getContacts()
                      .values
                      .where((contact) =>
                          circleMemberships[contact.coagContactId]
                              ?.contains(circle.key) ??
                          false)
                      .map((contact) => contact.details?.picture)
                      .whereType<List<int>>()
                      .map(Uint8List.fromList)
                      .toList()
                    // Shuffle when opening the page but not at each re-draw
                    ..shuffle(Random(_sessionSeed)),
                )))
            .toList(),
      );

  Widget _newCircleForm(
          BuildContext context, List<String> existingCircleNames) =>
      Form(
          key: _formKey,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                  controller: _newCircleController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: 'New circle name',
                  ),
                  // TODO: Instead just open the corresponding circle details?
                  validator: (value) {
                    if (existingCircleNames
                        .map((n) => n.toLowerCase())
                        .contains(value?.toLowerCase())) {
                      return 'This circle name already exists.';
                    }
                    return null;
                  },
                  onChanged: (_) => _formKey.currentState!.validate(),
                )),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: (_newCircleName.isEmpty)
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final circleId = await context
                                .read<CirclesListCubit>()
                                .addCircle(_newCircleName);
                            _resetState();
                            if (context.mounted) {
                              await Navigator.of(context)
                                  .push(CircleDetailsPage.route(circleId));
                            }
                          }
                        },
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 5),
              ]));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(context.loc.circles.capitalize())),
      body: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) =>
                    CirclesListCubit(context.read<ContactsRepository>())),
          ],
          child: BlocConsumer<CirclesListCubit, CirclesListState>(
              listener: (context, state) async {},
              builder: (context, state) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(children: [
                    Expanded(
                      child: _circlesGrid(
                          context, state.circles, state.circleMemberships),
                    ),
                    const SizedBox(height: 10),
                    _newCircleForm(context, state.circles.values.toList()),
                    const SizedBox(height: 10),
                  ])))));
}
