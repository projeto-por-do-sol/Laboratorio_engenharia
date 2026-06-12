import 'package:client_app/src/shared/models/ingrediente_item.dart';
import 'package:flutter/material.dart';

/*
 * Classe responsável por criar os checkbox de remoção de ingredientes na página
 * de informações do item.
 */

class RemoverIngrediente extends StatefulWidget {
  final List<IngredienteItem> ingredientes; //Recebe a lista de ingredientes do item

  final Function(List<IngredienteItem> selecionados) onChanged; //Callback (envia os ingredientes removidos para o pai)

  const RemoverIngrediente({
    super.key,
    required this.ingredientes,
    required this.onChanged,
  });

  @override
  State<RemoverIngrediente> createState() => _RemoverIngredienteState();
}

class _RemoverIngredienteState extends State<RemoverIngrediente> {
  final Set<IngredienteItem> _selecionados = {}; //Conjunto com os itens removidos

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.ingredientes.length,
      itemBuilder: (context, index) {
        final item = widget.ingredientes[index];
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
              color: marcado ? Theme.of(context).colorScheme.secondary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: marcado
                    ? Theme.of(context).colorScheme.primary
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
                    color: marcado ? Theme.of(context).colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: marcado
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  child: marcado
                      ? Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.secondary)
                      : null,
                ),

                const SizedBox(width: 12),

                // Texto
                Expanded(
                  child: Text(
                    item.nome[0].toUpperCase() + item.nome.substring(1).toLowerCase(),
                    style: TextStyle(
                      fontSize: 16,
                      color: marcado
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      decoration: marcado
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Theme.of(context).colorScheme.outline,
                      decorationThickness: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Label "Removido"
                if (marcado)
                  Text(
                    'Removido',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
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