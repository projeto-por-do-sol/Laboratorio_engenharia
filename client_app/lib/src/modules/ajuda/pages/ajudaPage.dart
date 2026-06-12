import 'package:client_app/src/shared/models/ajuda_model.dart';
import 'package:client_app/src/shared/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<AjudaModel> topicosAjuda = [
      AjudaModel(
        topicoAjuda: "Como realizar um pedido?",
        descricao: "Entre na página de um quiosque, escolha um item (você pode aumentar a quantidade no botão laranja, ou clicar no card do item para customizar o pedido). Após selecionar tudo, vá ao carrinho e finalize a compra.",
      ),
      AjudaModel(
        topicoAjuda: "Como acompanhar meu pedido?",
        descricao: "Após enviar o pedido, você pode acompanhar o status em tempo real na aba 'Meus Pedidos', desde a preparação até a saída para entrega.",
      ),
      AjudaModel(
        topicoAjuda: "Como cancelar um pedido?",
        descricao: "O cancelamento pode ser feito antes do quiosque começar a preparar o pedido ou após 30 minutos do pedido ser listado como 'Preparando' ou 'Entregando'. Vá em 'Meus Pedidos', selecione o pedido atual e clique em 'Cancelar'. Após esse prazo, entre em contato direto com o quiosque.",
      ),
      AjudaModel(
        topicoAjuda: "Como alterar a localização de entrega?",
        descricao: "Após criado o pedido, não é possível alterar a localização de entrega. Caso queira alterar, entre em contato direto com o quiosque.",
      ),
      AjudaModel(
        topicoAjuda: "Como editar meu perfil?",
        descricao: "Acesse a aba 'Perfil', clique em 'Modificar perfil' onde você poderá alterar seu nome, telefone de contato e e-mail salvos.",
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
