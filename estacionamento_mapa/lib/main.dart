import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estacionamento Monitorado',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Coordenadas centrais
  final LatLng inatelLocation = const LatLng(-22.2568, -45.7032);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Vagas - Equipe 11'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: inatelLocation,
          initialZoom: 17.5, // Zoom bem perto para ver as vagas
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.exemplo.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(-22.2571, -45.7030),
                width: 40,
                height: 40,
                child: const Icon(Icons.accessible, color: Colors.green, size: 35),
              ),
              Marker(
                point: const LatLng(-22.2572, -45.7031),
                width: 40,
                height: 40,
                child: const Icon(Icons.accessible, color: Colors.red, size: 35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}