import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:quiosque_app/src/shared/widget/mapa_selecao_page.dart';

/// Campo de seleção de localização do quiosque: mostra um minimapa com a
/// localização escolhida (ou um aviso para escolher). Ao tocar, abre a
/// [MapaSelecaoPage] centrada na localização do cliente; o ponto confirmado lá
/// é devolvido por [onChanged].
class SeletorLocalizacao extends StatelessWidget {
  final LatLng? valor;
  final ValueChanged<LatLng> onChanged;
  final String label;

  const SeletorLocalizacao({
    super.key,
    required this.valor,
    required this.onChanged,
    this.label = 'Localização do quiosque:',
  });

  Future<void> _abrirMapa(BuildContext context) async {
    final escolhido = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapaSelecaoPage(inicial: valor),
      ),
    );
    if (escolhido != null) onChanged(escolhido);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.outline)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: _preview(context, theme)),
                  // Camada transparente captura o toque para abrir o mapa cheio
                  // (o minimapa em si não é interativo).
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: () => _abrirMapa(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor == null
                ? 'Toque para escolher no mapa.'
                : 'Lat: ${valor!.latitude.toStringAsFixed(5)}, '
                    'Lng: ${valor!.longitude.toStringAsFixed(5)}',
            style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.outline.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _preview(BuildContext context, ThemeData theme) {
    if (valor == null) {
      return Container(
        color: theme.colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_location_alt_outlined,
                  size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text('Selecionar localização',
                  style: TextStyle(
                      fontSize: 14, color: theme.colorScheme.outline)),
            ],
          ),
        ),
      );
    }

    return IgnorePointer(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: valor!,
          initialZoom: 16,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.none),
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
              Marker(
                point: valor!,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: const Icon(Icons.location_on,
                    size: 40, color: Color(0xFFE63946)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
