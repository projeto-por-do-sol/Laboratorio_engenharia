import 'package:quiosque_app/src/shared/models/ajuda_model.dart';
import 'package:quiosque_app/src/shared/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<AjudaModel> topicosAjuda = [
      AjudaModel(
        topicoAjuda: "Como editar a página do quiosque?",
        descricao: "Na aba 'Quiosque', toque no ícone de lápis no canto da capa para entrar no modo de edição. Ali você pode trocar a imagem de banner, alterar o nome, definir o horário e os dias de funcionamento, o raio de atendimento e adicionar seções e itens. Toque no ícone de confirmar para sair da edição.",
      ),
      AjudaModel(
        topicoAjuda: "Como adicionar itens ao cardápio?",
        descricao: "No modo de edição da página do quiosque, adicione uma seção pré-definida (ex.: Lanches, Bebidas) e use 'Adicionar item' dentro dela. Informe nome, descrição, preço, foto, ingredientes e complementos do item e salve.",
      ),
      AjudaModel(
        topicoAjuda: "Como aceitar e acompanhar pedidos?",
        descricao: "Na aba 'Pedidos', os novos pedidos aparecem com a opção de aceitar. Toque em 'SIM' para aceitar ou em qualquer parte do card para ver os detalhes. A cor na lateral indica há quanto tempo o pedido está em aberto, e você pode avançar o status (Aceito → Preparando → Entregando → Finalizado).",
      ),
      AjudaModel(
        topicoAjuda: "Como cancelar um pedido?",
        descricao: "Abra o pedido na aba 'Pedidos' e toque em 'Cancelar'. É obrigatório informar o motivo do cancelamento antes de confirmar, para que o cliente seja notificado corretamente.",
      ),
      AjudaModel(
        topicoAjuda: "Como fazer um pedido pelo balcão?",
        descricao: "Na aba 'Pedidos', toque no botão '+'. Monte o pedido escolhendo os itens do cardápio, informe o nome do cliente no carrinho e finalize. Pedidos feitos pelo quiosque não possuem código de verificação nem localização de cliente.",
      ),
      AjudaModel(
        topicoAjuda: "Como gerenciar funcionários?",
        descricao: "Na aba 'Perfil', acesse 'Gerenciar funcionários' para cadastrar, editar ou remover funcionários. Gerentes e o dono podem visualizar os dados de login (usuário e senha) de cada funcionário.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajuda"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),

              ...topicosAjuda.map((topico) =>
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: CustomButton(
                    label: topico.topicoAjuda,
                    onPressed: (){
                      context.push('/ajudaTopico', extra: topico);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
