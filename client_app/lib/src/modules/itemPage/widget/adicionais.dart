import 'package:client_app/src/shared/models/adicionaisItem.dart';
import 'package:flutter/material.dart';

/*
 * Classe responsável por criar os checkbox de adição de complementos/adicionais
 * na página de informações do item.
 */

class Adicionais extends StatefulWidget {
  final List<AdicionaisItem> adicionais; //Recebe a lista de adicionais do item

  final Function(List<AdicionaisItem> selecionados) onChanged; //Callback (envia os adicionais selecionados para o pai)

  const Adicionais({
    super.key,
    required this.adicionais,
    required this.onChanged,
  });

  @override
  State<Adicionais> createState() => _Adicionais();
}

class _Adicionais extends State<Adicionais> {
  final Set<AdicionaisItem> _selecionados = {}; //Conjunto com os itens adicionados
  
  dynamic corrigeValorPreco(int item) {
    double itemCorrigido = item / 100;
    return itemCorrigido.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    // var verdeTexto = 0xFF64AFC6;
    // var verdeFundo = 0xFFEBF5F0;

    var amareloTexto = 0xff8B6540;
    var amareloDetalhes = 0xFFFDD06A;
    var amareloFundo = 0xFFFFF3DC;

    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.adicionais.length,
      itemBuilder: (context, index) {
        final item = widget.adicionais[index];
        final marcado = _selecionados.contains(item);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (marcado) {
                _selecionados.remove(item);
              } else {
                _selecionados.add(item);
              }
              widget.onChanged(_selecionados.toList());
            });
          },
          // Container com o checkbox e o texto
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: marcado ? Color(amareloFundo) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: marcado
                      ? Color(amareloDetalhes)
                      : Theme.of(context).colorScheme.secondary
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: marcado ? Color(amareloDetalhes) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: marcado
                          ? Color(amareloDetalhes)
                          : Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  child: marcado
                      ? Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.outline)
                      : null,
                ),

                const SizedBox(width: 12),

                // Texto
                Expanded(
                  child: Text(
                    item.nomeAdicional[0].toUpperCase() + item.nomeAdicional.substring(1).toLowerCase(),
                    style: TextStyle(
                      fontSize: 16,
                      color: marcado
                          ? Color(amareloTexto)
                          : Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  "+ R\$${corrigeValorPreco(item.precoAdicional)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: marcado ? Color(amareloTexto) : Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}