import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/providers/carrinho_provider/carrinho_provider.dart';
import 'package:client_app/providers/cliente_provider/cliente_provider.dart';
import 'package:client_app/providers/pedido_provider/pedido_provider.dart';
import 'package:client_app/src/shared/models/item_carrinho.dart';
import 'package:client_app/src/shared/widget/CustomDivider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarrinhoPage extends ConsumerStatefulWidget {
  const CarrinhoPage({super.key});

  @override
  ConsumerState<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends ConsumerState<CarrinhoPage> {
  bool _isSending = false;

  Widget identificadorQuiosque(QuiosqueCarrinho quiosque){
    double heightImagem = 80;
    double widthImagem = 90;

    dynamic imagemBanner(){
      return ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        child: ApiClient.imagemUrl(quiosque.imgBannerQuiosque) != null
            ? Image.network(
          ApiClient.imagemUrl(quiosque.imgBannerQuiosque)!,
          height: heightImagem,
          width: widthImagem,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: heightImagem,
              width: widthImagem,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40,),
            );
          },
        )
            : Container(
          height: heightImagem,
          width: widthImagem,
          color: Colors.grey[300],
          child: const Icon(Icons.image, color: Colors.grey, size: 40,),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          imagemBanner(),

          const SizedBox(width: 10,),

          Expanded(
            child: Text(quiosque.nomeQuiosque.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onTertiary,
              )
              ,),
          ),
          IconButton(
              onPressed: _isSending ? null : (){
                ref.read(carrinhoProvider.notifier).removerQuiosque(quiosque);
              },
              icon: Icon(
                Icons.cancel_outlined,
                size: 30,
                color: Theme.of(context).colorScheme.onTertiary,
              )
          ),
        ],
      ),
    );
  }

  Widget itensCarrinho(ItemCarrinho item, QuiosqueCarrinho quiosque) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.nomeItem,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Qtde: ${item.qtdeItem}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(
                width: 80,
                child: Text(
                  'R\$ ${(item.valorTotal / 100).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              IconButton(
                onPressed: _isSending ? null : () {
                  ref.read(carrinhoProvider.notifier).removerItem(quiosque, item);
                },
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ],
          ),

          if(item.ingredientes.isNotEmpty || item.adicionais.isNotEmpty)
            const Divider(height: 10),

          if (item.ingredientes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Remover:", style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.outline,
                  )
                  ),
                  ...item.ingredientes.map((ingrediente) =>
                      Text('• ${ingrediente.nome}', style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      )
                      ),
                  )],
              ),
            ),

          if (item.adicionais.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Adicionais:", style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.outline,
                  )
                  ),
                  ...item.adicionais.map((adicional) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${adicional.nomeAdicional}', style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      )
                      ),

                      Text('R\$ ${(adicional.precoAdicional / 100).toStringAsFixed(2).replaceAll('.', ',')}', style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      )
                      )
                    ],
                  )
                  )],
              ),
            ),

        ],
      ),
    );
  }

  void _mostrarLoginObrigatorio() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'Entre na sua conta para fazer pedidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Text('Cancelar',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget botaoEnviarPedido() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSending ? null : () async {
          final cliente = ref.read(clienteProvider).value;
          if (cliente == null) {
            _mostrarLoginObrigatorio();
            return;
          }

          setState(() {
            _isSending = true;
          });

          final router = GoRouter.of(context);

          try {
            bool sucesso = await ref.read(pedidoProvider.notifier).criarPedido();

            if (sucesso) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Pedido realizado!".toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      duration: const Duration(seconds: 3),
                    )
                );
                router.pushReplacement('/pedidos');
              }
            } else {
              throw Exception("Falha na criação do pedido");
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erro ao realizar pedido!".toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    duration: const Duration(seconds: 3),
                  )
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isSending = false;
              });
            }
          }
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),

        child: _isSending
            ? const SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        )
            : const Text("Fazer pedido!", style:
        TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final carrinho = ref.watch(carrinhoProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Carrinho'),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          carrinho.isEmpty
              ? Center(
            child: Text(
              'Seu carrinho está vazio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline),
            ),
          )
              : SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ...carrinho.entries.map((entry) {
                    var quiosque = entry.key;
                    var itens = entry.value;

                    return Column(
                      children: [
                        identificadorQuiosque(quiosque),
                        for (var item in itens)
                          itensCarrinho(item, quiosque),
                      ],
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bloqueia interações na tela se a API estiver processando o pedido
          if (_isSending)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black12,
            ),
        ],
      ),

      bottomNavigationBar: carrinho.isNotEmpty
          ? Container(
        color: Colors.transparent,
        child: botaoEnviarPedido(),
      )
          : null,
    );
  }
}