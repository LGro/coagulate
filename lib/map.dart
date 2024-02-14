// Copyright 2024 Lukas Grossberger
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'cubit/peer_contact_cubit.dart';

// TODO: Work with clusters when zoomed out
//       https://github.com/mapbox/mapbox-maps-flutter/blob/main/example/lib/cluster.dart

class MapPage extends StatefulWidget {
  const MapPage();

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}, ${annotation.textField}");
  }
}

class MapPageState extends State<MapPage> {
  MapPageState();

  MapboxMap? mapboxMap;
  PointAnnotationManager? annotationManager;

  void _onMapCreated(MapboxMap mapboxMap, List<PeerContact> contacts) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations
        .createPointAnnotationManager()
        .then((annotationManager) async {
          await annotationManager.createMulti(
            contacts
              .where((contact) => contact.lng != null && contact.lat !=null)
              // TODO: Somehow the point annotation doesn't show, but the circle does; double check
              .map((contact) => PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(contact.lng!, contact.lat!)
                ).toJson(),
                textOffset: [0.0, -2.0],
                textColor: Colors.black.value,
                iconSize: 1.3,
                iconOffset: [0.0, -5.0],
                symbolSortKey: 10,
                textField: contact.contact.displayName,
                iconImage: Icons.favorite.toString(),
              ))
              .toList()
          );
          annotationManager
            .addOnPointAnnotationClickListener(AnnotationClickListener());
    });
  }

  /* Interesting things to consider for the future:
    pointAnnotationManager?.deleteAll();
  */

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => PeerContactCubit()..refreshContactsFromSystem(),
        child:  BlocConsumer<PeerContactCubit, PeerContactState>(
    listener: (context, state) async {
    }, builder: (context, state) => MapWidget(
      resourceOptions: ResourceOptions(
          accessToken: const String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')),
      onMapCreated: (mapboxMap) => _onMapCreated(mapboxMap, state.contacts.values.asList()),
    )));
}
