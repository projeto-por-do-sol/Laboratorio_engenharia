import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/quiosque_provider/quiosque_provider.dart';
import 'package:client_app/src/shared/models/item_carrinho.dart';
import 'package:client_app/src/shared/models/item_quiosque.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';
import 'package:client_app/src/shared/widget/CardItens.dart';
import 'package:client_app/src/shared/widget/CustomDivider.dart';
import 'package:client_app/src/shared/widget/appBar.dart';
import 'package:flutter/material.dart';
import 'package:client_app/providers/carrinho_provider/carrinho_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuiosquePage extends ConsumerStatefulWidget {
  final QuiosqueModel quiosque;

  QuiosquePage({
    super.key,
    required this.quiosque,
  });

  @override
  ConsumerState<QuiosquePage> createState() => _QuiosquePageState();
}

class _QuiosquePageState extends ConsumerState<QuiosquePage> {
  List<ItemQuiosque> listaItens = [];

  var corVerde = 0xff4A8C7A;
  var corVermelha = 0xffFF5000;
  int precoCarrinho = 0;
  List<ItemCarrinho> _itensAdicionarCarrinho = [];
  Key _cardsKey = UniqueKey();
  String _categoriaSelecionada = 'Todos';

  dynamic funcionamentoQuiosque(){
    bool quiosqueAberto = widget.quiosque.estaAberto;

    return Container(
      height: 30,
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: quiosqueAberto? Color(corVerde) : Color(corVermelha),
        borderRadius: BorderRadius.circular(20),
      ),
      child:
        quiosqueAberto ? Text("Aberto",
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary, fontWeight: FontWeight.w600),
        ) : Text("Fechado",
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary, fontWeight: FontWeight.w600),
        ),
    );
  }

  dynamic notaQuiosque(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(20),
      ),

      height: 30,
      child: Row(
          children: [
            Icon(Icons.star_rate_rounded,
              color: Theme.of(context).colorScheme.outline,
              size: 14,
            ),

            const SizedBox(width: 3),

            Text(
              "${widget.quiosque.avaliacaoQuiosque.toStringAsFixed(1)} (${widget.quiosque.qtdeAvaliacoes.toString()})",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

          ]
      ),
    );
  }

  dynamic containerInfoQuiosque(IconData icone, String texto, String subtexto){
    return Container(
      width: 120,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1,
        )
      ),
      child: Column(
        children: [
          Icon(icone, size: 20, color: Theme.of(context).colorScheme.outline),
          SizedBox(height: 5,),
          Text(texto, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(subtexto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget botaoAdicionar() {
    bool disponivelPedir = !widget.quiosque.estaAberto || !widget.quiosque.disponivelEntrega;

    calcularQtdItens() {
      int qtdItens = 0;
      for (var item in _itensAdicionarCarrinho) {
        qtdItens += item.qtdeItem;
      }
      return qtdItens;
    }

    calcularPrecoCarrinho() {
      double precoCarrinho = 0;
      for (var item in _itensAdicionarCarrinho) {
        precoCarrinho += item.qtdeItem *
            listaItens
                .firstWhere((element) => element.nomeItem == item.nomeItem)
                .precoItem;
      }
      return precoCarrinho / 100;
    }

    return ElevatedButton(
      onPressed: disponivelPedir ? null : () {
        QuiosqueCarrinho quiosqueCarrinho = QuiosqueCarrinho(
          idQuiosque: widget.quiosque.idQuiosque,
          nomeQuiosque: widget.quiosque.nomeQuiosque,
          imgBannerQuiosque: widget.quiosque.imgBannerQuiosque,
        );

        bool tudoSucesso = true;

        for (var item in _itensAdicionarCarrinho) {
          bool sucessoItem = ref.read(carrinhoProvider.notifier).adicionarItem(quiosqueCarrinho, item);

          if (!sucessoItem) {
            tudoSucesso = false;
          }
        }

        ScaffoldMessenger.of(context).clearSnackBars();

        if (tudoSucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Itens adicionados com sucesso!".toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              duration: const Duration(seconds: 3),
            ),
          );

          setState(() {
            _itensAdicionarCarrinho.clear();
            _cardsKey = UniqueKey();
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Houve um erro ao adicionar algum itens".toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,

        disabledBackgroundColor: Theme.of(context).colorScheme.primary,
        disabledForegroundColor: Theme.of(context).colorScheme.onSecondary,

        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),

      child:
      !disponivelPedir ?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  calcularQtdItens().toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    // color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                Text(
                  calcularQtdItens() < 2 ? "item" : "itens",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    // color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Adicionar ao carrinho",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              // color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "R\$ ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    // color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                Text(
                  calcularPrecoCarrinho().toStringAsFixed(2).replaceAll('.', ','),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    // color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ) :
          Text("Não é possível pedir aqui!", style:
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
    );
  }

  void _onItemChanged(ItemCarrinho itemAtualizado) {
    setState(() {
      // 1. Procura se o item já está no carrinho
      int index = _itensAdicionarCarrinho.indexWhere(
        (i) => i.nomeItem == itemAtualizado.nomeItem,
      );

      if (index != -1) {
        // 2. Se existe e a nova qtd é > 0, atualiza
        if (itemAtualizado.qtdeItem > 0) {
          _itensAdicionarCarrinho[index] = itemAtualizado;
        } else {
          // 3. Se a qtd chegou a 0, remove da lista
          _itensAdicionarCarrinho.removeAt(index);
        }
      } else if (itemAtualizado.qtdeItem > 0) {
        // 4. Se não existe e tem qtd, adiciona
        _itensAdicionarCarrinho.add(itemAtualizado);
      }
    });
  }

  /// Lista de categorias disponíveis, começando por "Todos".
  List<String> _categoriasDisponiveis() {
    final categorias = <String>['Todos'];
    for (var item in listaItens.where((i) => i.disponivel)) {
      if (!categorias.contains(item.secaoItem)) categorias.add(item.secaoItem);
    }
    return categorias;
  }

  /// Filtro de categorias em formato de chips horizontais.
  Widget _buildFiltroCategorias() {
    final categorias = _categoriasDisponiveis();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final selecionada = categoria == _categoriaSelecionada;

          return GestureDetector(
            onTap: () => setState(() => _categoriaSelecionada = categoria),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: selecionada
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onTertiary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              child: Text(
                categoria,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selecionada
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Agrupa os itens disponíveis por categoria (secaoItem) e monta uma seção
  /// para cada uma: nome da categoria, um divider e, em seguida, os itens.
  /// Respeita a categoria selecionada no filtro.
  List<Widget> _buildSecoes() {
    final disponiveis = listaItens
        .where((item) =>
            item.disponivel &&
            (_categoriaSelecionada == 'Todos' ||
                item.secaoItem == _categoriaSelecionada))
        .toList();

    final Map<String, List<ItemQuiosque>> porCategoria = {};
    for (var item in disponiveis) {
      porCategoria.putIfAbsent(item.secaoItem, () => []).add(item);
    }

    final bool desabilitado =
        !widget.quiosque.estaAberto || !widget.quiosque.disponivelEntrega;

    final quiosqueCarrinho = QuiosqueCarrinho(
      idQuiosque: widget.quiosque.idQuiosque,
      nomeQuiosque: widget.quiosque.nomeQuiosque,
      imgBannerQuiosque: widget.quiosque.imgBannerQuiosque,
    );

    final List<Widget> secoes = [];
    porCategoria.forEach((categoria, itens) {
      secoes.add(
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            categoria,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );

      secoes.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: CustomDivider(),
        ),
      );

      secoes.add(const SizedBox(height: 10));

      secoes.addAll(
        itens.map(
          (item) => CardItens(
            desabilitado: desabilitado,
            item: item,
            quiosque: quiosqueCarrinho,
            onChanged: _onItemChanged,
          ),
        ),
      );
    });

    return secoes;
  }

  @override
  Widget build(BuildContext context) {
    // Banner em 16:9 (mesma proporção usada no app do quiosque ao recortar a
    // capa), para o recorte exibido bater com o que o dono enquadrou.
    double tamanhoImagem = MediaQuery.of(context).size.width * 9 / 16;
    final quiosque = widget.quiosque;

    final itensAsync = ref.watch(itensQuiosqueProvider(quiosque.idQuiosque));
    listaItens = itensAsync.value ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: CustomAppBar(),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
                children: [

                  SizedBox(
                    height: tamanhoImagem,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.grey, size: 40),
                          ),
                        ),

                        if (ApiClient.imagemUrl(quiosque.imgBannerQuiosque) != null)
                          Image.network(
                            ApiClient.imagemUrl(quiosque.imgBannerQuiosque)!,
                            height: tamanhoImagem,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: tamanhoImagem,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40,),
                              );
                            },
                          ),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  funcionamentoQuiosque(),
                                  notaQuiosque(),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xffABA387),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(widget.quiosque.nomeQuiosque.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onTertiary,
                                  ),
                                ),
                              ),
                            ]
                          )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  SafeArea(
                    key: _cardsKey,
                    top: false,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              containerInfoQuiosque(Icons.hourglass_bottom_rounded, "~${widget.quiosque.tempoEspera} min", "Espera"),
                              containerInfoQuiosque(Icons.location_on_rounded, "${widget.quiosque.distanciaQuiosque}m", "Distância"),
                              containerInfoQuiosque(Icons.access_time_filled_rounded,
                                  widget.quiosque.estaAberto ?
                                  widget.quiosque.horarioFecha :
                                  widget.quiosque.horarioAbre,

                                  widget.quiosque.estaAberto ?
                                  "Fecha" : "Abre"),
                            ]
                          ),

                          SizedBox(height: 20,),

                          if (itensAsync.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            )
                          else if (itensAsync.hasError)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Não foi possível carregar os itens.",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else ...[
                            _buildFiltroCategorias(),

                            const SizedBox(height: 20),

                            ..._buildSecoes(),
                          ],

                        ],
                      ),
                  ),
                ],
              ),
          ),
        ],
      ),

      bottomNavigationBar: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        ),
        child: _itensAdicionarCarrinho.isNotEmpty
          ? Padding(
            key: ValueKey('botao'),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              left: 16,
              right: 16,
              top: 10,
            ),
            child: botaoAdicionar(),
          )
          : SizedBox.shrink(key: ValueKey('vazio')),
      ),
    );
  }
}