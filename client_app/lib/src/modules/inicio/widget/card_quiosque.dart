import 'package:client_app/data/services/api_client.dart';
import 'package:client_app/src/modules/inicio/widget/categorias.dart';
import 'package:client_app/src/shared/models/quiosque_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardQuiosque extends StatefulWidget {
  final QuiosqueModel quiosque;

  const CardQuiosque({
    super.key,
    required this.quiosque,
  });

  @override
  State<CardQuiosque> createState() => _CardQuiosqueState();
}

class _CardQuiosqueState extends State<CardQuiosque> {
  var corVerde = 0xff4A8C7A;
  var corVermelha = 0xffFF5000;

  dynamic imagemBanner(){
    double tamanhoImagem = 90.0;
    return ClipRRect(
      //Tamanho Imagem: 150x90
      // borderRadius: BorderRadius.circular(20),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      child: ApiClient.imagemUrl(widget.quiosque.imgPerfilQuiosque) != null
          ? Image.network(
        ApiClient.imagemUrl(widget.quiosque.imgPerfilQuiosque)!,
        height: double.infinity,
        width: tamanhoImagem,
        fit: BoxFit.cover,
        // fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: double.infinity,
            width: tamanhoImagem,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40,),
          );
        },
      )
          : Container(
        height: double.infinity,
        width: tamanhoImagem,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey, size: 40,),
      ),
    );
  }

  dynamic notaQuiosque(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(950),
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
              widget.quiosque.avaliacaoQuiosque.toStringAsFixed(1),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

          ]
      ),
    );
  }

  dynamic infoQuiosque(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('~${widget.quiosque.tempoEspera} min'),

        const SizedBox(width: 5,),

        Text("·"),

        const SizedBox(width: 5,),

        Icon(Icons.location_on_rounded, color: Theme.of(context).colorScheme.outline, size: 14,),
        Text("${widget.quiosque.distanciaQuiosque}m"),

        const SizedBox(width: 5,),

        Text("·"),

        const SizedBox(width: 5,),

        Row(
            children: [
              Icon(Icons.access_time_filled_rounded, color: Theme.of(context).colorScheme.outline, size: 14,),
              Text(
                "${widget.quiosque.horarioAbre} - ${widget.quiosque.horarioFecha}",
                style: TextStyle(fontSize: 14),
              ),
            ]
        )

      ],
    );
  }

  dynamic categoriasQuiosque(){
    return SizedBox(
      height: 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.quiosque.categorias?.length ?? 0,
        itemBuilder: (context, index) {
          final categoria = widget.quiosque.categorias![index];
          return CategoriasQuiosques(categoria: categoria);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).unfocus();
        context.push('/quiosquePage', extra: widget.quiosque);
        },

      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 1,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        height: 150,
        width: double.infinity,
        child: Row(
          children: [

            imagemBanner(),

            Expanded(
              child: Container(
                // color: Colors.purple,
                // width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, size: 10, color:
                          widget.quiosque.estaAberto ?
                          Color(corVerde) :
                          Color(corVermelha)),

                        SizedBox(width: 5,),

                        Expanded(
                          child: Text(
                            widget.quiosque.nomeQuiosque,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),

                        notaQuiosque(),
                      ],
                    ),

                    // const SizedBox(height: 3),
                    Spacer(),

                    infoQuiosque(),

                    // SizedBox(height: 5,),

                    Spacer(),

                    categoriasQuiosque(),

                    Spacer(),

                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
