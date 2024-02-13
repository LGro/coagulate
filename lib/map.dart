// Copyright 2024 Lukas Grossberger
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'cubit/peer_contact_cubit.dart';

// TODO: Work with clusters when zoomed out
//       https://github.com/mapbox/mapbox-maps-flutter/blob/main/example/lib/cluster.dart

class ContactLocation {
  ContactLocation(this.lng, this.lat, this.contactId);
  final num lng;
  final num lat;
  final String contactId;
}

class MapPage extends StatefulWidget {
  const MapPage();

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class AnnotationClickListener extends OnCircleAnnotationClickListener {
  @override
  void onCircleAnnotationClick(CircleAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
  }
}

class MapPageState extends State<MapPage> {
  MapPageState();

  MapboxMap? mapboxMap;
  CircleAnnotationManager? circleAnnotationManager;

  void _onMapCreated(MapboxMap mapboxMap, List<PeerContact> contacts) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations
        .createCircleAnnotationManager()
        .then((circleAnnotationManager) async {
          await circleAnnotationManager.createMulti(
            // TODO: Add text annotation with name
            contacts
              .where((contact) => contact.lng != null && contact.lat !=null)
              .map((contact) => CircleAnnotationOptions(
                geometry: Point(
                  coordinates: Position(contact.lng!, contact.lat!)).toJson(),
                circleRadius: 12,
              ))
              .toList()
          );
          circleAnnotationManager
            .addOnCircleAnnotationClickListener(AnnotationClickListener());
    });
  }

  /* Interesting things to consider for the future:

  PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
              0.381457,
              6.687337,
            )).toJson(),
            textField: "custom-icon",
            textOffset: [0.0, -2.0],
            textColor: Colors.red.value,
            iconSize: 1.3,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            iconImage: Icons.favorite.toString())

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
