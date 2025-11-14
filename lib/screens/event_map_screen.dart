import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event_model.dart'; 

class EventMapScreen extends StatelessWidget {
  final Event event;

  const EventMapScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final lat = event.latitude;
    final lng = event.longitude;

    if (lat == null || lng == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa do Evento'),
          foregroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 50, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  'Coordenadas de GPS não disponíveis para o evento: "${event.title}".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
              ],
            ),
          ),
        ),
      );
    }

    final eventLocation = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(
        title: Text('Localização: ${event.location}'),
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: eventLocation,
          zoom: 16, 
        ),
        markers: {
          Marker(
            markerId: MarkerId(event.id ?? 'default'),
            position: eventLocation,
            infoWindow: InfoWindow(
              title: event.title,
              snippet: event.location,
            ),
          ),
        },
        mapType: MapType.normal,
        zoomControlsEnabled: true,
      ),
    );
  }
}