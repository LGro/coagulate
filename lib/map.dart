import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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
    print("onAnnotationClick, id: ${annotation.id}");
  }
}

class MapPageState extends State<MapPage> {
  MapPageState();

  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations
        .createPointAnnotationManager()
        .then((pointAnnotationManager) async {
      // NOTE: There is also createMulti
      pointAnnotationManager.create(PointAnnotationOptions(
          geometry: Point(coordinates: Position(8.682127, 50.110924)).toJson(),
          iconImage: "car-15"));
      pointAnnotationManager
          .addOnPointAnnotationClickListener(AnnotationClickListener());
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
          accessToken: String.fromEnvironment("COAGULATE_MAPBOX_PUBLIC_TOKEN")),
      onMapCreated: _onMapCreated,
    );

    return mapWidget;
  }
}
