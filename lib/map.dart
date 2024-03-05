import 'dart:async';
import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
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
          builder: (context, state) {
            const mapboxToken =
                String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN');

            final markers = state.contacts.values
                // TODO: Bring back to filter out the contacts with actual coordinate infos
                // .where((contact) => contact.lng != null && contact.lat != null)
                .map((contact) => Marker(
                    height: 60,
                    width: 100,
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
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            '${contact.contact.name.first} ${contact.contact.name.last}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          // TODO: Display label of the address
                          const Text(
                            '(label)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.location_pin,
                              size: 26, color: Colors.deepPurple)
                        ]))))
                .toList();

            final allLats = markers.map((m) => m.point.latitude).asList();
            final allLons = markers.map((m) => m.point.longitude).asList();
            allLats.sort();
            allLons.sort();

            return FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  (allLats.last + allLats.first) / 2,
                  (allLons.last + allLons.first) / 2,
                ),
                initialZoom: 3,
                maxZoom: 15,
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: (mapboxToken.isEmpty)
                      ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                      // TODO: Add {r} along with retinaMode.isHighDensity and TileLayer.retinaMode
                      : 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}?access_token=${mapboxToken}',
                ),
                MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                  maxClusterRadius: 100,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 15,
                  markers: markers,
                  builder: (context, markers) => DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepPurple),
                      child: Center(
                          child: Text(markers.length.toString(),
                              style: const TextStyle(color: Colors.white)))),
                )),
                RichAttributionWidget(
                    showFlutterMapAttribution: false,
                    attributions: [
                      if (mapboxToken.isEmpty)
                        TextSourceAttribution(
                          'OpenStreetMap',
                          onTap: () async => launchUrl(Uri.parse(
                              'https://www.openstreetmap.org/copyright')),
                        )
                      else
                        TextSourceAttribution(
                          'Mapbox',
                          onTap: () async => launchUrl(
                              Uri.parse('https://www.mapbox.com/about/maps/')),
                        )
                    ])
              ],
            );
          }));
}
