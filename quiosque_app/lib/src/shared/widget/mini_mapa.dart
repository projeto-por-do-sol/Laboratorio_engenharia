import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:quiosque_app/data/services/quiosque_service.dart';

/// Minimapa que mostra a localização de onde o pedido foi criado (cliente) e a
/// localização atual do funcionário sobre um mapa real (tiles do OpenStreetMap
/// via CartoDB). As coordenadas do cliente vêm do back-end (campos
/// clienteLat/clienteLng do pedido) e a do funcionário é obtida pelo
/// dispositivo.
///
/// O mapa é desenhado imediatamente centrado no cliente — não esperamos o GPS.
/// Assim que a posição do funcionário chega, adicionamos o segundo marcador e
/// reenquadramos a câmera para mostrar os dois pontos. Isso evita o spinner
/// bloqueante enquanto o dispositivo adquire um fix de GPS (que pode demorar).
class MiniMapa extends StatefulWidget {
  final double clienteLat;
  final double clienteLng;

  const MiniMapa({
    super.key,
    required this.clienteLat,
    required this.clienteLng,
  });

  @override
  State<MiniMapa> createState() => _MiniMapaState();
}

class _MiniMapaState extends State<MiniMapa> {
  final MapController _mapController = MapController();

  Position? _funcionario;
  // Indica que a busca pelo GPS terminou (com ou sem sucesso), para só então
  // mostrar a mensagem de "localização indisponível" se for o caso.
  bool _gpsResolvido = false;
  // O MapController só aceita fitCamera depois que o mapa foi montado.
  bool _mapaPronto = false;

  static const _corCliente = Color(0xFFE63946);
  static const _corFuncionario = Color(0xFF1D3557);

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    // 1) Último ponto conhecido: chega quase instantaneamente.
    final ultima = await QuiosqueService.instance.obterUltimaLocalizacao();
    if (!mounted) return;
    if (ultima != null) _atualizarFuncionario(ultima);

    // 2) Fix atual (mais preciso, porém mais lento). Refina o marcador.
    final atual = await QuiosqueService.instance.obterLocalizacao();
    if (!mounted) return;
    if (atual != null) _atualizarFuncionario(atual);

    setState(() => _gpsResolvido = true);
  }

  void _atualizarFuncionario(Position pos) {
    setState(() => _funcionario = pos);
    _enquadrarPontos();
  }

  /// Reenquadra a câmera para mostrar cliente e funcionário.
  void _enquadrarPontos() {
    if (_funcionario == null || !_mapaPronto) return;
    final cliente = LatLng(widget.clienteLat, widget.clienteLng);
    final funcionario =
        LatLng(_funcionario!.latitude, _funcionario!.longitude);
    // Pontos coincidentes (ou quase) geram um bounds de área zero, e o
    // fitCamera calcula um zoom infinito/NaN -> "Unsupported operation:
    // Infinity or NaN toInt" no flutter_map. Nesse caso só centralizamos no
    // ponto com um zoom fixo.
    final distancia = Geolocator.distanceBetween(
      cliente.latitude,
      cliente.longitude,
      funcionario.latitude,
      funcionario.longitude,
    );
    if (distancia < 1) {
      _mapController.move(cliente, 16);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([cliente, funcionario]),
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cliente = LatLng(widget.clienteLat, widget.clienteLng);
    final funcionario = _funcionario != null
        ? LatLng(_funcionario!.latitude, _funcionario!.longitude)
        : null;

    double? distancia;
    if (funcionario != null) {
      distancia = Geolocator.distanceBetween(
        cliente.latitude,
        cliente.longitude,
        funcionario.latitude,
        funcionario.longitude,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localização do pedido:',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _construirMapa(cliente, funcionario),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _legenda(_corCliente, 'Cliente'),
            const SizedBox(width: 16),
            if (funcionario != null) _legenda(_corFuncionario, 'Você'),
            const Spacer(),
            if (distancia != null)
              Text(_formatarDistancia(distancia),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.outline)),
          ],
        ),
        if (_gpsResolvido && funcionario == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                'Localização do funcionário indisponível (permissão de GPS negada).',
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline.withValues(alpha: 0.7))),
          ),
      ],
    );
  }

  Widget _construirMapa(LatLng cliente, LatLng? funcionario) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: cliente,
        initialZoom: 16,
        onMapReady: () {
          _mapaPronto = true;
          // Caso o GPS já tenha respondido antes do mapa montar.
          _enquadrarPontos();
        },
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.quiosque.app',
        ),
        if (funcionario != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [cliente, funcionario],
                strokeWidth: 3,
                color: Colors.black45,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            _marcador(cliente, _corCliente),
            if (funcionario != null) _marcador(funcionario, _corFuncionario),
          ],
        ),
      ],
    );
  }

  Marker _marcador(LatLng ponto, Color cor) {
    return Marker(
      point: ponto,
      width: 40,
      height: 40,
      alignment: Alignment.topCenter,
      child: Icon(Icons.location_on, size: 40, color: cor),
    );
  }

  Widget _legenda(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, size: 18, color: cor),
        const SizedBox(width: 2),
        Text(texto, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  String _formatarDistancia(double metros) {
    if (metros < 1000) return '${metros.toStringAsFixed(0)} m';
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }
}
