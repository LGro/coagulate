// Copyright 2024 Lukas Grossberger
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  late MapController controller;

  @override
  void initState() {
    super.initState();
    controller =
        MapController(initMapWithUserPosition: const UserTrackingOption());
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return OSMFlutter(
      controller: controller,
      mapIsLoading: const Center(child: CircularProgressIndicator()),
      osmOption: const OSMOption(showContributorBadgeForOSM: true),
      onMapIsReady: (p0) async {
        await controller.addMarker(GeoPoint(latitude: 49.878, longitude: 8.64),
            markerIcon:
                const MarkerIcon(icon: Icon(Icons.person_pin, size: 56)));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
