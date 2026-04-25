// Importa a biblioteca principal de UI do Flutter
import 'package:flutter/material.dart';

// Importa a biblioteca de mapa (OpenStreetMap)
import 'package:flutter_map/flutter_map.dart';

// Biblioteca para trabalhar com coordenadas geográficas (latitude/longitude)
import 'package:latlong2/latlong.dart';

// Função principal que inicia o app
void main() {
  runApp(const MyApp());
}

// Classe principal do app (estrutura base)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título do aplicativo
      title: 'AchôParô',

      // Tema visual padrão
      theme: ThemeData(primarySwatch: Colors.indigo),

      // Tela inicial do app
      home: const MapScreen(),
    );
  }
}

// Tela do mapa (com estado, pois pode mudar no futuro)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// Estado da tela do mapa
class _MapScreenState extends State<MapScreen> {
  // Coordenadas centrais do mapa (Inatel)
  final LatLng inatelLocation = const LatLng(-22.2568, -45.7032);

  @override
  Widget build(BuildContext context) {
    // Pega a largura da tela (usado para responsividade)
    final largura = MediaQuery.of(context).size.width;

    return Scaffold(
      // Barra superior do app
      appBar: AppBar(
        title: const Text('AchôParô - Monitoramento de Vagas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      // Corpo da tela
      body: LayoutBuilder(
        // LayoutBuilder permite adaptar o layout conforme o tamanho da tela
        builder: (context, constraints) {
          // Verifica se é tablet (largura maior que 600)
          bool isTablet = constraints.maxWidth > 600;

          // Define tamanho do ícone proporcional à tela
          double iconSize = isTablet
              ? largura *
                    0.04 // menor em tablet (mais espaço disponível)
              : largura * 0.08; // maior em celular

          // Define tamanho do marcador
          double markerSize = isTablet ? 60 : 40;

          return FlutterMap(
            // Configurações do mapa
            options: MapOptions(
              initialCenter: inatelLocation, // centro do mapa
              initialZoom: isTablet ? 18 : 17.5, // zoom inicial
            ),

            // Camadas do mapa
            children: [
              // Camada base (mapa do OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                // Identificação do app (boa prática)
                userAgentPackageName: 'com.exemplo.app',
              ),

              // Camada de marcadores (vagas)
              MarkerLayer(
                markers: [
                  // Marcador 1 (vaga livre)
                  Marker(
                    point: const LatLng(-22.2571, -45.7030), // posição no mapa
                    width: markerSize,
                    height: markerSize,

                    // Ícone exibido
                    child: Icon(
                      Icons.accessible,
                      color: Colors.green, // verde = disponível
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
                      color: Colors.red, // vermelho = ocupada
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
