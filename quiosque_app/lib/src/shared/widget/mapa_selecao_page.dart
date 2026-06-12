import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:quiosque_app/data/services/quiosque_service.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';

/// Página de mapa para escolher a localização do quiosque.
///
/// Abre centrada na localização atual do cliente (GPS). Ao tocar em um ponto do
/// mapa, um marcador aparece e um modal pergunta se o usuário deseja usar aquela
/// localização. Ao confirmar, a página é fechada retornando o [LatLng] escolhido.
class MapaSelecaoPage extends StatefulWidget {
  /// Localização já definida anteriormente (para reabrir centrado nela).
  final LatLng? inicial;

  const MapaSelecaoPage({super.key, this.inicial});

  @override
  State<MapaSelecaoPage> createState() => _MapaSelecaoPageState();
}

class _MapaSelecaoPageState extends State<MapaSelecaoPage> {
  final MapController _mapController = MapController();

  // Centro padrão (Brasil) enquanto o GPS não responde e não há valor inicial.
  static const LatLng _centroPadrao = LatLng(-15.793889, -47.882778);

  LatLng? _selecionado;
  // Localização atual do usuário (GPS), exibida como um pin distinto.
  LatLng? _usuario;
  bool _mapaPronto = false;

  static const _corSelecionado = Color(0xFFE63946);
  static const _corUsuario = Color(0xFF1D3557);

  @override
  void initState() {
    super.initState();
    _selecionado = widget.inicial;
    // Sempre busca a posição do usuário (para o pin); só recentraliza a câmera
    // nela quando não há um ponto inicial definido.
    _carregarUsuario(centralizar: widget.inicial == null);
  }

  Future<void> _carregarUsuario({required bool centralizar}) async {
    final ultima = await QuiosqueService.instance.obterUltimaLocalizacao();
    if (!mounted) return;
    if (ultima != null) {
      final ponto = LatLng(ultima.latitude, ultima.longitude);
      setState(() => _usuario = ponto);
      if (centralizar) _moverCamera(ponto);
    }

    final atual = await QuiosqueService.instance.obterLocalizacao();
    if (!mounted) return;
    if (atual != null) {
      final ponto = LatLng(atual.latitude, atual.longitude);
      setState(() => _usuario = ponto);
      if (centralizar) _moverCamera(ponto);
    }
  }

  void _moverCamera(LatLng ponto) {
    if (_mapaPronto) _mapController.move(ponto, 16);
  }

  Future<void> _aoTocar(LatLng ponto) async {
    setState(() => _selecionado = ponto);
    final confirmar = await mostrarModalConfirmacaoDestaque(
      context,
      pergunta: 'Deseja usar esta localização como a do quiosque?',
      icone: Icons.location_on_outlined,
    );
    if (confirmar == true && mounted) {
      Navigator.of(context).pop(ponto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final centro = _selecionado ?? widget.inicial ?? _centroPadrao;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar localização'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 16,
              onMapReady: () {
                _mapaPronto = true;
                if (_selecionado == null && widget.inicial == null) {
                  _carregarUsuario(centralizar: true);
                }
              },
              onTap: (_, ponto) => _aoTocar(ponto),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.quiosque.app',
              ),
              MarkerLayer(
                markers: [
                  // Pin da localização atual do usuário.
                  if (_usuario != null)
                    Marker(
                      point: _usuario!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.my_location,
                          size: 32, color: _corUsuario),
                    ),
                  // Pin da localização escolhida para o quiosque.
                  if (_selecionado != null)
                    Marker(
                      point: _selecionado!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on,
                          size: 44, color: _corSelecionado),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Toque no mapa para escolher a localização do quiosque.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
