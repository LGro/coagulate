import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_page.dart';
import 'cubit/contacts_cubit.dart';

LatLng _contactToLatLng(CoagContact contact) {
  final rng = Random();
  return LatLng(rng.nextDouble() * 50, rng.nextDouble() * 12);
  // return LatLng(contact.lat!, contact.lng!);
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => CoagContactCubit()..refreshContactsFromSystem(),
      child: BlocConsumer<CoagContactCubit, CoagContactState>(
        listener: (context, state) async {},
        builder: (context, state) => FlutterMap(
          options: MapOptions(
            // initialCenter: LatLng((maxLatLng.latitude + minLatLng.latitude) / 2,
            //     (maxLatLng.longitude + minLatLng.longitude) / 2),
            initialZoom: 6,
            maxZoom: 15,
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: (const String.fromEnvironment(
                          'COAGULATE_MAPBOX_PUBLIC_TOKEN')
                      .isEmpty)
                  ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                  // TODO: Add {r} along with retinaMode.isHighDensity and TileLayer.retinaMode
                  : 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}?access_token=${const String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')}',
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(40, 40),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                maxZoom: 15,
                // TODO: Bring back to filter out the contacts with actual coordinate infos
                // .where((contact) => contact.lng != null && contact.lat != null)
                markers: state.contacts.values
                    .map(
                      (contact) => Marker(
                          height: 30,
                          width: 30,
                          point: _contactToLatLng(contact),
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () {
                              unawaited(Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ContactPage(
                                          contactId: contact.contact.id))));
                            },
                            // TODO: Increase size
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${contact.contact.name.first} ${contact.contact.name.last}',
                                        style: TextStyle(fontSize: 100),
                                      ),
                                      SizedBox(width: 5.0),
                                      const Icon(Icons.location_pin,
                                          size: 100, color: Colors.deepPurple)
                                    ])),
                          )),
                    )
                    .toList(),
                builder: (context, markers) => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  if (const String.fromEnvironment(
                          'COAGULATE_MAPBOX_PUBLIC_TOKEN')
                      .isEmpty)
                    TextSourceAttribution(
                      'OpenStreetMap',
                      onTap: () async => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright')),
                    )
                  else
                    TextSourceAttribution(
                      'Mapbox',
                      onTap: () async => launchUrl(
                          Uri.parse('https://www.mapbox.com/about/maps/')),
                    ),
                ])
          ],
        ),
      ));
}
