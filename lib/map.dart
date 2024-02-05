// Copyright 2024 Lukas Grossberger
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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

  final contactLocations = [
    ContactLocation(8.682127, 50.110924, '2433'),
    ContactLocation(6.682127, 45.110924, '2431'),
  ];

  MapboxMap? mapboxMap;
  CircleAnnotationManager? circleAnnotationManager;

  void _onMapCreated(MapboxMap mapboxMap) {
    print(" Token");
    print(const String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN'));
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations
        .createCircleAnnotationManager()
        .then((circleAnnotationManager) async {
      // NOTE: There is also createMulti
      await circleAnnotationManager.createMulti(
        // TODO: Add text annotation with conLoc.contactId based contact name
        contactLocations.map((conLoc) => CircleAnnotationOptions(
          geometry: Point(coordinates: Position(conLoc.lng, conLoc.lat)).toJson(),
          circleRadius: 12,
          )).toList());
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
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      resourceOptions: ResourceOptions(
          accessToken: const String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')),
      onMapCreated: _onMapCreated,
    );

    return mapWidget;
  }
}
