import 'package:flutter/material.dart';

class ContainerBusca extends StatefulWidget {
  final Function(String filtro, String ordenacao) trocaFiltro;
  final Function(String termo) onSearch;
  final VoidCallback onRefresh;
  final String? nomeCliente;

  const ContainerBusca({
    super.key,
    required this.trocaFiltro,
    required this.onSearch,
    required this.onRefresh,
    this.nomeCliente,
  });

  @override
  State<ContainerBusca> createState() => _ContainerBuscaState();
}

class _ContainerBuscaState extends State<ContainerBusca> {
  TextEditingController pesquisaController = TextEditingController();
  String filtroSelecionado = 'distancia';
  String ordencaoSelecionado = 'menor';

  void _notificarMudanca() {
    widget.trocaFiltro(filtroSelecionado, ordencaoSelecionado);
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeExibido = widget.nomeCliente ?? 'visitante';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Olá, $nomeExibido",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Qual vai ser hoje?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  widget.onRefresh();
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          SizedBox(
            child: TextField(
              autocorrect: false,
              textAlignVertical: TextAlignVertical.center,
              controller: pesquisaController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              cursorColor: Theme.of(context).colorScheme.secondary,
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                filled: true,
                fillColor: Theme.of(context).colorScheme.tertiary,
                hintText: "Pesquisar quiosque",
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 24,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                suffixIcon: pesquisaController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          pesquisaController.clear();
                          widget.onSearch('');
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 15),

          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Filtrar por: ",
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: const Size(90, 40),
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      filtroSelecionado =
                          filtroSelecionado == 'distancia'
                              ? 'avaliacao'
                              : 'distancia';
                    });
                    _notificarMudanca();
                  },
                  child: Text(
                    filtroSelecionado == 'distancia' ? 'Distância' : 'Avaliação',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      ordencaoSelecionado =
                          ordencaoSelecionado == 'menor' ? 'maior' : 'menor';
                    });
                    _notificarMudanca();
                  },
                  icon: ordencaoSelecionado == 'menor'
                      ? Icon(Icons.keyboard_arrow_down)
                      : Icon(Icons.keyboard_arrow_up),
                  iconSize: 30,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(5),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
