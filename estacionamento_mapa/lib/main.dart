// Importa a biblioteca principal de UI do Flutter
import 'package:flutter/material.dart';

// Importa a biblioteca de mapa (OpenStreetMap)
import 'package:flutter_map/flutter_map.dart';

// Biblioteca para trabalhar com coordenadas geográficas (latitude/longitude)
import 'package:latlong2/latlong.dart';

// Biblioteca para pegar a localização do celular (Certifique-se de adicionar no pubspec.yaml)
import 'package:geolocator/geolocator.dart';

// Função principal que inicia o app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AchôParô',
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
  // Coordenadas centrais do mapa (Inatel)
  final LatLng inatelLocation = const LatLng(-22.2568, -45.7032);
  
  // Variável que guarda a localização do usuário (começa vazia)
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndTrack();
  }

  // Função para pedir permissão e rastrear o usuário
  Future<void> _checkPermissionAndTrack() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Teste se o serviço de localização está ativo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    // Se chegou aqui, temos permissão. Vamos escutar a posição:
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Atualiza a cada 2 metros
      ),
    ).listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AchôParô - Monitoramento'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double iconSize = isTablet ? largura * 0.04 : largura * 0.08;
          double markerSize = isTablet ? 60 : 40;

          return FlutterMap(
            options: MapOptions(
              initialCenter: inatelLocation,
              initialZoom: isTablet ? 18 : 17.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.exemplo.app',
              ),
              MarkerLayer(
                markers: [
                  // --- MARCADOR DO USUÁRIO (PIN AZUL) ---
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: markerSize,
                      height: markerSize,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                  // --- MARCADORES DAS VAGAS ---
                  // Marcador 1 (vaga livre)
                  Marker(
                    point: const LatLng(-22.2571, -45.7030),
                    width: markerSize,
                    height: markerSize,
                    child: Icon(
                      Icons.accessible,
                      color: Colors.green,
                      size: iconSize,
                    ),
                  ),

                  // Marcador 2 (vaga ocupada)
                  Marker(
                    point: const LatLng(-22.2572, -45.7031),
                    width: markerSize,
                    height: markerSize,
                    child: Icon(
                      Icons.accessible,
                      color: Colors.red,
                      size: iconSize,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}