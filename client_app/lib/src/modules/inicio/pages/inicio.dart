import 'package:client_app/data/services/cliente_service.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:client_app/src/modules/inicio/widget/Container_busca.dart';
import 'package:client_app/src/modules/inicio/widget/card_quiosque.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';
import 'package:client_app/src/shared/widget/CustomDivider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _termoBusca = '';
  String _criterioOrdenacao = 'distancia';
  String _ordenacao = 'menor';

  @override
  void initState() {
    super.initState();
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    await ClienteService.instance.obterLocalizacao();
  }

  List<QuiosqueModel> _processarLista(List<QuiosqueModel> quiosques) {
    var resultado = [...quiosques];

    if (_termoBusca.isNotEmpty) {
      final termo = _termoBusca.toLowerCase();
      resultado = resultado
          .where((q) => q.nomeQuiosque.toLowerCase().contains(termo))
          .toList();
    }

    resultado.sort((a, b) {
      final int comparacao = _criterioOrdenacao == 'distancia'
          ? double.parse(a.distanciaQuiosque)
              .compareTo(double.parse(b.distanciaQuiosque))
          : a.avaliacaoQuiosque.compareTo(b.avaliacaoQuiosque);
      return _ordenacao == 'menor' ? comparacao : -comparacao;
    });

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final clienteAsync = ref.watch(clienteProvider);
    final nomeCliente = clienteAsync.value?.nomeCompleto.split(' ').first;
    final quiosquesAsync = ref.watch(quiosquesProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              ContainerBusca(
                nomeCliente: nomeCliente,
                onSearch: (termo) {
                  setState(() {
                    _termoBusca = termo;
                  });
                },
                trocaFiltro: (filtro, ordenacao) {
                  setState(() {
                    _criterioOrdenacao = filtro;
                    _ordenacao = ordenacao;
                  });
                },
                onRefresh: () => ref.invalidate(quiosquesProvider),
              ),

              const SizedBox(height: 30),

              quiosquesAsync.when(
                skipLoadingOnRefresh: false,
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
                error: (erro, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Não foi possível carregar os quiosques.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                data: (quiosques) =>
                    _listaQuiosques(context, _processarLista(quiosques)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaQuiosques(
      BuildContext context, List<QuiosqueModel> listaFiltrada) {
    if (listaFiltrada.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Nenhum quiosque encontrado.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      );
    }

    // Entrega disponível "aqui e agora": só conta se o quiosque faz entrega
    // para esta posição E está aberto — quiosque fechado não aceita pedido.
    bool entregaDisponivel(QuiosqueModel q) =>
        q.disponivelEntrega && q.estaAberto;

    final comEntrega =
        listaFiltrada.where(entregaDisponivel).toList();
    final semEntrega =
        listaFiltrada.where((q) => !entregaDisponivel(q)).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (comEntrega.isNotEmpty) ...[
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Entrega aí",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ...comEntrega.map((quiosque) => CardQuiosque(quiosque: quiosque)),
          ],

          if (semEntrega.isNotEmpty) ...[
            if (comEntrega.isNotEmpty) ...[
              CustomDivider(),
              const SizedBox(height: 20),
            ],

            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Não entrega aí",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ...semEntrega.map((quiosque) => CardQuiosque(quiosque: quiosque)),
          ],
        ],
      ),
    );
  }
}
