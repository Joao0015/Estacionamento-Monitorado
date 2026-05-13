import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

// Paleta de cores centralizada
class AppColors {
  static const Color primary = Color(0xFF00A86B);
  static const Color darkBg = Color(0xFF0B2545);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color red = Color(0xFFE53935);
  static const Color orange = Color(0xFFFFA726);
  static const Color blue = Color(0xFF2196F3);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AchôParô',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                "ACHÔPARÔ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "Achou. Parou.",
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
              const Spacer(),
              const Text(
                "Sua vaga, sem voltas.",
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
              const Text(
                "Encontre. Estacione. Siga.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                  ),
                  child: const Text("Entrar",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: const Text("Criar conta",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == 0 ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                i == 0 ? AppColors.primary : Colors.white30,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, "Início", 0),
            _navItem(Icons.map_outlined, "Mapa", 1),
            const SizedBox(width: 40),
            _navItem(Icons.history, "Histórico", 2),
            _navItem(Icons.person_outline, "Perfil", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool active = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: active ? AppColors.primary : AppColors.textGrey, size: 24),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: active ? AppColors.primary : AppColors.textGrey,
                  fontWeight:
                      active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Olá, usuário!",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Bem-vindo ao AchôParô",
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textGrey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6)
                    ],
                  ),
                  child: const Icon(Icons.notifications_none,
                      color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Buscar endereço ou setor",
                  hintStyle:
                      TextStyle(color: AppColors.textGrey, fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: AppColors.textGrey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildVagasCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Setores",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Ver todos",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectorCard("C", "Centro", "32% disponível", "12", "38",
                AppColors.orange),
            const SizedBox(height: 10),
            _buildSectorCard("S", "Shopping Park", "68% disponível", "34",
                "50", AppColors.primary),
            const SizedBox(height: 10),
            _buildSectorCard("U", "Universidade", "15% disponível", "6", "40",
                Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildVagasCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Vagas próximas a você",
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
              Row(
                children: [
                  Text("Atualizado agora",
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  SizedBox(width: 4),
                  Icon(Icons.refresh, size: 14, color: AppColors.primary),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("23",
                        style: TextStyle(
                            fontSize: 42, fontWeight: FontWeight.bold)),
                    Text("vagas disponíveis",
                        style: TextStyle(fontSize: 13)),
                    Text("em um raio de 500 m",
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              ),
              Container(
                width: 110,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.map, color: AppColors.primary, size: 50),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: const Text("Ver no mapa",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorCard(String letter, String title, String status,
      String free, String total, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 18,
            child: Text(letter,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(status,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: free,
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  TextSpan(
                      text: " / $total",
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 13)),
                ]),
              ),
              const Text("livres",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAP SCREEN — ESP32 FUNCIONAL + LEGENDA DINÂMICA
// ============================================================
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

  // Status do ESP32 — lógica original preservada
  String _statusVagaESP = "livre";
  Timer? _espTimer;

  String _filtroAtivo = "Todos";

  @override
  void initState() {
    super.initState();
    _checkPermissionAndTrack();
    // Timer original do ESP32 (a cada 2 segundos)
    _espTimer = Timer.periodic(
        const Duration(seconds: 2), (timer) => _buscarDadosESP32());
  }

  // Função original para buscar status do ESP32 dentro do INATEL
  Future<void> _buscarDadosESP32() async {
    try {
      final response = await http.get(Uri.parse('http://10.100.16.172/'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() => _statusVagaESP = response.body.trim());
        }
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
          if (_isFirstLocation) {
            _mapController.move(userLocation!, 17.5);
            _isFirstLocation = false;
          }
        }
      });
    }
  }

  void _centralizarUsuario() {
    if (userLocation != null) {
      _mapController.move(userLocation!, 17.5);
    }
  }

  @override
  void dispose() {
    _espTimer?.cancel();
    super.dispose();
  }

  // Cálculo dinâmico da legenda baseado no ESP32
  // Total: 2 vagas (1 ESP32 + 1 estática do idoso, sempre livre)
  int get _vagasLivres => _statusVagaESP == "livre" ? 2 : 1;
  int get _vagasOcupadas => _statusVagaESP == "ocupada" ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation ?? inatelLocation,
              initialZoom: 17.5,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'br.edu.inatel.achoparo.projeto.fetin.v2',
                additionalOptions: const {
                  'User-Agent': 'AchoParo/1.0 FlutterMap/6.0'
                },
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              MarkerLayer(
                markers: [
                  // Localização do usuário
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.blue.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 4)
                          ],
                        ),
                      ),
                    ),

                  // ⭐ VAGA MONITORADA PELO ESP32 (acessível)
                  // A cor muda em tempo real conforme o sensor envia "livre" ou "ocupada"
                  Marker(
                    point: const LatLng(-22.256890, -45.696178),
                    width: 40,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _statusVagaESP == "ocupada"
                              ? AppColors.red
                              : AppColors.primary,
                          size: 44,
                        ),
                        const Positioned(
                          top: 8,
                          child: Icon(Icons.accessible,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),

                  // VAGA ESTÁTICA — Idoso (sempre livre)
                  Marker(
                    point: const LatLng(-22.256745, -45.696048),
                    width: 40,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 44,
                        ),
                        Positioned(
                          top: 8,
                          child: Icon(Icons.elderly,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16, MediaQuery.of(context).padding.top + 8, 16, 12),
              color: Colors.white,
              child: Row(
                children: const [
                  Icon(Icons.menu, color: AppColors.textDark),
                  Expanded(
                    child: Center(
                      child: Text("Mapa",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Icon(Icons.filter_list, color: AppColors.textDark),
                ],
              ),
            ),
          ),

          // Filtros
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              child: Row(
                children: [
                  _filterBtn("Todos"),
                  _filterBtn("Livres"),
                  _filterBtn("Ocupadas"),
                ],
              ),
            ),
          ),

          // Botões flutuantes laterais
          Positioned(
            right: 16,
            bottom: 180,
            child: Column(
              children: [
                _floatBtn(Icons.navigation_outlined, () {}),
                const SizedBox(height: 10),
                _floatBtn(Icons.my_location, _centralizarUsuario),
              ],
            ),
          ),

          // ⭐ Card legenda inferior — DINÂMICA com base no ESP32
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _legendItem(
                      AppColors.primary, "Livre", _vagasLivres.toString()),
                  _legendItem(
                      AppColors.red, "Ocupada", _vagasOcupadas.toString()),
                  _legendItem(AppColors.blue, "Seu local", null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String text) {
    final bool active = _filtroAtivo == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filtroAtivo = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(text,
              style: TextStyle(
                  color: active ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _floatBtn(IconData icon, VoidCallback onTap) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textDark),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, String? count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
            if (count != null)
              Text(count,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// HISTORY & PROFILE
// ============================================================
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text("Histórico",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text("Perfil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
  }
}