import 'package:quiosque_app/src/shared/models/ajuda_model.dart';
import 'package:flutter/material.dart';

class AjudaTopico extends StatelessWidget {
  final AjudaModel assunto;

  const AjudaTopico({
    super.key,
    required this.assunto,
  });

  Widget assuntoAjuda(BuildContext context){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(assunto.topicoAjuda,
        textAlign: TextAlign.center,
        style:
          TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onTertiary),
        ),
    );
  }

  Widget descricaoAjuda(BuildContext context){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(assunto.descricao,
        textAlign: TextAlign.justify,
        style:
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.outline,
          height: 1.8,
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(assunto.topicoAjuda.toString()),
        // centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            assuntoAjuda(context),
            descricaoAjuda(context),
          ],
        ),
      ),
    );
  }
}
