import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; // Importante para o ESP32
import 'dart:async';

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
  final LatLng inatelLocation = const LatLng(-22.2568, -45.7032);
  LatLng? userLocation;
  
  // --- NOVAS VARIÁVEIS PARA O ESP32 ---
  String _statusVaga2 = "livre"; 
  Timer? _espTimer;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndTrack();
    
    // Inicia a verificação do ESP32 a cada 2 segundos
    _espTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _buscarDadosESP32();
    });
  }

  // Função que conversa com o ESP32
  Future<void> _buscarDadosESP32() async {
    try {
      // SUBSTITUA PELO IP QUE APARECE NO SEU ARDUINO IDE
      final response = await http.get(Uri.parse('http://10.97.14.172/')); 
      
      if (response.statusCode == 200) {
        setState(() {
          _statusVaga2 = response.body.trim(); 
        });
      }
    } catch (e) {
      print("Erro ao conectar no ESP32: $e");
    }
  }

  @override
  void dispose() {
    _espTimer?.cancel(); // Para o timer ao fechar o app
    super.dispose();
  }

  Future<void> _checkPermissionAndTrack() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
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

                  // --- VAGA MONITORADA PELO BOTÃO ---
                  Marker(
                    point: const LatLng(-22.2571, -45.7030),
                    width: markerSize,
                    height: markerSize,
                    child: Icon(
                      Icons.accessible,
                      // MUDANÇA AQUI: Cor depende do status do ESP32
                      color: _statusVaga2 == "ocupada" ? Colors.red : Colors.green,
                      size: iconSize,
                    ),
                  ),

                  // Marcador 2 (Exemplo estático)
                  Marker(
                    point: const LatLng(-22.2572, -45.7031),
                    width: markerSize,
                    height: markerSize,
                    child: Icon(
                      Icons.accessible,
                      color: _statusVaga2 == "ocupada" ? Colors.red : Colors.green,
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