// Copyright 2024 Lukas Grossberger
import 'dart:async';
import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'contact_page.dart';
import 'cubit/contacts_cubit.dart';

// TODO: Work with clusters when zoomed out
//       https://github.com/mapbox/mapbox-maps-flutter/blob/main/example/lib/cluster.dart

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  AnnotationClickListener(
      {required this.context, required this.annotationToContactIds});
  final BuildContext context;
  final Map<String, String> annotationToContactIds;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print(
        "onAnnotationClick label: ${annotation.textField} contact: ${annotationToContactIds[annotation.id]}");
    unawaited(Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ContactPage(contactId: annotationToContactIds[annotation.id]!),
      ),
    ));
  }
}

Map<String, dynamic> _contactToGeo(CoagContact contact) {
  // TODO: Replace random dummy data with actual contact locations
  final rng = Random();
  return Point(coordinates: Position(rng.nextInt(50), rng.nextInt(12)))
      .toJson();
  return Point(coordinates: Position(contact.lng!, contact.lat!)).toJson();
}

Future<Uint8List> _contactMarkerImage() async {
  // TODO: Pick different asset
  final bytes = await rootBundle.load('assets/images/ellet.png');
  return bytes.buffer.asUint8List();
}

class MapPageState extends State<MapPage> {
  MapPageState();

  MapboxMap? mapboxMap;
  PointAnnotationManager? annotationManager;

  Future<void> _onMapCreated(
      MapboxMap mapboxMap, List<CoagContact> contacts) async {
    this.mapboxMap = mapboxMap;
    final markerImage = await _contactMarkerImage();
    await mapboxMap.annotations
        .createPointAnnotationManager()
        .then((annotationManager) async {
      final annotations = await annotationManager.createMulti(contacts
          // TODO: Bring back to filter out the contacts with actual coordinate infos
          //.where((contact) => contact.lng != null && contact.lat != null)
          .map((contact) => PointAnnotationOptions(
              geometry: _contactToGeo(contact),
              textOffset: [0.0, -2.0],
              textColor: Colors.black.value,
              iconSize: 0.2,
              iconOffset: [0.0, -5.0],
              symbolSortKey: 10,
              textField: contact.contact.displayName,
              image: markerImage))
          .toList());
      Map<String, String> annotationToContactIds = {};
      for (var i = 0; i < annotations.length; i++) {
        annotationToContactIds[annotations[i]!.id] = contacts[i].contact.id;
      }
      // TODO: It seems to be bad practice to pass context like this; work with a callback instead?
      annotationManager.addOnPointAnnotationClickListener(
          AnnotationClickListener(
              context: context,
              annotationToContactIds: annotationToContactIds));
    });
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => CoagContactCubit()..refreshContactsFromSystem(),
      child: BlocConsumer<CoagContactCubit, CoagContactState>(
          listener: (context, state) async {},
          builder: (context, state) => MapWidget(
                cameraOptions: CameraOptions(pitch: 0, zoom: 2),
                onMapCreated: (mapboxMap) async =>
                    _onMapCreated(mapboxMap, state.contacts.values.asList()),
              )));
}
