import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AchoParo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00A86B), // Verde do PDF [cite: 9]
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A86B)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1; // Começa direto no Mapa para você testar

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF00A86B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
        ],
      ),
    );
  }
}

// --- TELA DE INÍCIO (ESTILO PDF) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Olá, usuário!", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const Text("Bem-vindo ao AchoParo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildSectorCard("Centro", "32% disponível", Colors.orange), // [cite: 11]
              const SizedBox(height: 10),
              _buildSectorCard("Shopping Park", "68% disponível", Colors.green), // [cite: 11]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectorCard(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(status, style: TextStyle(color: color)),
          ]),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}

// --- TELA DO MAPA (RECUPERANDO O ESP32 E VAGAS) ---
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final MapController _mapController = MapController();

  final LatLng inatelLocation = const LatLng(-22.2568, -45.7032);
  LatLng? userLocation;

  bool _isFirstLocation = true;

  String _statusVagaESP = "livre"; // Lógica original do ESP32
  Timer? _espTimer;

  @override
  void initState() {

    super.initState();
    _checkPermissionAndTrack();
    // Inicia o Timer do ESP32 (IP original que você usava)
    _espTimer = Timer.periodic(const Duration(seconds: 2), (timer) => _buscarDadosESP32());
  }

  Future<void> _buscarDadosESP32() async {
    try {
      final response = await http.get(Uri.parse('http://10.97.14.172/')); 
      if (response.statusCode == 200) {
        setState(() => _statusVagaESP = response.body.trim());
      }
    } catch (e) {
      debugPrint("Erro ESP32: $e");
    }
  }

  Future<void> _checkPermissionAndTrack() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission != LocationPermission.denied) {
    Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          userLocation = LatLng(position.latitude, position.longitude);
        });

        // SÓ MOVE O MAPA SE FOR A PRIMEIRA VEZ (AO ENTRAR NO APP)
        if (_isFirstLocation) {
          _mapController.move(userLocation!, 17.5);
          _isFirstLocation = false; // TRAVA O MOVIMENTO AUTOMÁTICO
        }
      }
    });
  }
}

  @override
  void dispose() {
    _espTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation ?? inatelLocation,
              initialZoom: 17.5, 
              maxZoom: 18.0
              ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.edu.inatel.achoparo.projeto.fetin.v2',
                // ADICIONE ESTA LINHA ABAIXO:
                additionalOptions: const {'User-Agent': 'AchoParo/1.0 FlutterMap/6.0'},
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              MarkerLayer(
                markers: [
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  
                  // VAGA MONITORADA PELO SEU ESP32
                  Marker(
                    point: const LatLng(-22.2571, -45.7030),
                    child: Icon(
                      Icons.accessible,
                      color: _statusVagaESP == "ocupada" ? Colors.red : const Color(0xFF00A86B),
                      size: 45,
                    ),
                  ),

                  // VAGA ESTÁTICA 2 (Que você tinha no código anterior)
                  Marker(
                    point: const LatLng(-22.2572, -45.7031),
                    child: const Icon(
                      Icons.elderly,
                      color: Color(0xFF00A86B),
                      size: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Filtros Flutuantes (Corrigido para POSITIONED) 
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterBtn("Todos", true),
                _filterBtn("Livres", false),
                _filterBtn("Ocupadas", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00A86B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Histórico (Ver PDF página 1)")));
  }
}