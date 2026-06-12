import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:quiosque_app/data/api/api_exception.dart';
import 'package:quiosque_app/providers/pagina_quiosque_provider/pagina_quiosque_provider.dart';
import 'package:quiosque_app/providers/sessao_provider/sessao_provider.dart';
import 'package:quiosque_app/src/shared/models/cardapio_item.dart';
import 'package:quiosque_app/src/shared/models/pagina_quiosque.dart';
import 'package:quiosque_app/src/shared/models/secao.dart';
import 'package:quiosque_app/src/shared/utils/formatters.dart';
import 'package:quiosque_app/src/shared/utils/image_picker_util.dart';
import 'package:quiosque_app/src/shared/utils/imagem_remota.dart';
import 'package:quiosque_app/src/shared/utils/secoes_predefinidas.dart';
import 'package:quiosque_app/src/shared/widget/modais.dart';

class PaginaQuiosquePage extends ConsumerStatefulWidget {
  const PaginaQuiosquePage({super.key});

  @override
  ConsumerState<PaginaQuiosquePage> createState() => _PaginaQuiosquePageState();
}

class _PaginaQuiosquePageState extends ConsumerState<PaginaQuiosquePage> {
  bool get _editando => ref.watch(editandoQuiosqueProvider);
  set _editando(bool valor) =>
      ref.read(editandoQuiosqueProvider.notifier).definir(valor);

  PaginaQuiosqueNotifier get _notifier =>
      ref.read(paginaQuiosqueProvider.notifier);

  /// Executa uma ação que fala com a API, exibindo erros amigáveis.
  Future<void> _executar(Future<void> Function() acao) async {
    try {
      await acao();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginaAsync = ref.watch(paginaQuiosqueProvider);
    final theme = Theme.of(context);
    // Apenas gerente ou dono podem alterar as informações do quiosque.
    final podeEditar = ref.watch(cargoAtualProvider).podeGerenciar;
    if (!podeEditar && _editando) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _editando = false;
      });
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: paginaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _erroView(theme),
          data: (pagina) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cabecalho(pagina, theme, podeEditar),
                const SizedBox(height: 8),
                if (_editando) _adicionarSecaoBotao(theme),
                ...pagina.secoes.map((s) => _secaoWidget(s, theme)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _erroView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('Não foi possível carregar o quiosque.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.outline)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  ref.read(paginaQuiosqueProvider.notifier).recarregar(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(PaginaQuiosque pagina, ThemeData theme, bool podeEditar) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: _editando ? _trocarBanner : null,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[350],
                  child: provedorImagem(pagina.capaPath) != null
                      ? Image(
                          image: provedorImagem(pagina.capaPath)!,
                          fit: BoxFit.cover)
                      : null,
                ),
              ),
            ),
            if (_editando)
              Positioned.fill(
                child: Center(
                  child: IconButton(
                    onPressed: _trocarBanner,
                    icon: Icon(Icons.file_upload_outlined, size: 28),
                  ),
                ),
              ),

            // Apenas gerente/dono enxergam o botão de edição.
            if (podeEditar)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _editando = !_editando,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black.withValues(alpha: 0.25),
                    child: Icon(_editando ? Icons.check : Icons.edit,
                        size: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),

        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 20, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: _editando ? _editarNome : null,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          pagina.nome,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 10,),
                      if (_editando)
                        Icon(Icons.edit, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _editando ? _indicadoresEdicao(pagina, theme) : _indicadoresView(pagina, theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _indicadoresView(PaginaQuiosque pagina, ThemeData theme) {
    final cor = theme.colorScheme.outline;
    Widget item(IconData icone, String texto) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 20, color: cor),
            const SizedBox(width: 2),
            Text(texto, style: TextStyle(fontSize: 14, color: cor)),
          ],
        );
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        item(Icons.star_rate_rounded, pagina.avaliacao.toStringAsFixed(1),),
        item(Symbols.reviews_rounded, '${pagina.qtdeAvaliacoes} avaliações'),
        item(Icons.access_time_filled_rounded,
            pagina.temHorario ? '${pagina.horarioAbre} → ${pagina.horarioFecha}' : '?'),
        item(Symbols.my_location_rounded, pagina.raio != null ? '${pagina.raio} m' : '?'),
        // Seleção de dias da semana desativada (ver _indicadoresEdicao).
        // item(Icons.calendar_today_rounded,
        //     pagina.temDias ? pagina.diasResumo : '?'),
      ],
    );
  }

  Widget _indicadoresEdicao(PaginaQuiosque pagina, ThemeData theme) {
    final cor = theme.colorScheme.outline;

    Widget editavel(IconData icone, String texto, VoidCallback onTap) =>
        InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 20, color: cor),
              SizedBox(width: 2),
              Text(texto, style: TextStyle(fontSize: 16, color: cor)),
              SizedBox(width: 10),
              Icon(Icons.edit, size: 20, color: cor),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            editavel(
              Icons.access_time_filled_rounded,
              pagina.temHorario ? '${pagina.horarioAbre} -> ${pagina.horarioFecha}' : '?',
              _editarHorario,
            ),
            editavel(
              Symbols.my_location_rounded,
              pagina.raio != null ? '${pagina.raio} m' : '?',
              _editarRaio,
            ),
          ],
        ),
        // Seleção de dias da semana desativada por ora.
        // const SizedBox(height: 8),
        // editavel(
        //   Icons.calendar_today_rounded,
        //   pagina.temDias ? pagina.diasResumo : 'Dias de funcionamento',
        //   _editarDias,
        // ),
      ],
    );
  }

  Widget _adicionarSecaoBotao(ThemeData theme) {
    return _linhaAdicionar(theme, 'Adicionar seção', _adicionarSecao,
        fontWeight: FontWeight.w700);
  }

  Widget _linhaAdicionar(ThemeData theme, String texto, VoidCallback onTap,
      {FontWeight fontWeight = FontWeight.w500}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 20, color: theme.colorScheme.outline),
            const SizedBox(width: 6),
            Text(texto,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeight,
                    color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _secaoWidget(Secao secao, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text('${secao.nome}:',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.outline)),
              ),
              if (_editando)
                InkWell(
                  onTap: () => _removerSecao(secao),
                  child: Icon(Icons.delete_outline,
                      size: 22, color: theme.colorScheme.outline),
                ),
            ],
          ),
        ),
        Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        const SizedBox(height: 8),
        ...secao.itens.map((item) => _itemWidget(secao, item, theme)),
        if (_editando)
          _linhaAdicionar(theme, 'Adicionar item',
              () => _adicionarItem(secao.id)),
      ],
    );
  }

  Widget _itemWidget(Secao secao, CardapioItem item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _editando
              ? () => _editarItem(secao.id, item)
              : () => context.push('/itemDescricao', extra: item),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: provedorImagem(item.imgPath) != null
                    ? Image(
                        image: provedorImagem(item.imgPath)!,
                        fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.fastfood,
                            color: theme.colorScheme.outline)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nome,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  if (item.descricao.isNotEmpty)
                    Text(item.descricao,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.7))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(formatarPreco(item.preco),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _trocarBanner() async {
    final path = await escolherImagem(context, aspectRatio: aspectRatioBanner);
    if (path != null) _executar(() => _notifier.setCapa(path));
  }

  Future<void> _editarNome() async {
    final pagina = ref.read(paginaQuiosqueProvider).value;
    if (pagina == null) return;
    final novo = await mostrarModalCampo(context,
        label: 'Nome do quiosque:',
        textoConfirmar: 'Confirmar',
        valorInicial: pagina.nome);
    if (novo != null) _executar(() => _notifier.setNome(novo));
  }

  Future<void> _editarHorario() async {
    final pagina = ref.read(paginaQuiosqueProvider).value;
    if (pagina == null) return;
    final res = await mostrarModalHorario(context,
        abreInicial: pagina.horarioAbre ?? '',
        fechaInicial: pagina.horarioFecha ?? '');
    if (res != null) _executar(() => _notifier.setHorario(res.$1, res.$2));
  }

  Future<void> _editarRaio() async {
    final pagina = ref.read(paginaQuiosqueProvider).value;
    if (pagina == null) return;
    final novo = await mostrarModalCampo(context,
        label: 'Raio de atendimento:',
        textoConfirmar: 'Adicionar',
        valorInicial: pagina.raio ?? '',
        numerico: true);
    if (novo != null) _executar(() => _notifier.setRaio(novo));
  }

  Future<void> _removerSecao(Secao secao) async {
    final confirmar = await mostrarModalConfirmacaoDestaque(
      context,
      pergunta: 'Deseja remover a categoria "${secao.nome}"?',
    );
    if (confirmar == true) _executar(() => _notifier.removerSecao(secao.id));
  }

  // Future<void> _editarDias() async {
  //   final pagina = ref.read(paginaQuiosqueProvider).value;
  //   if (pagina == null) return;
  //   final dias = await mostrarModalDias(context,
  //       diasIniciais: pagina.diasFuncionamento);
  //   if (dias != null) _notifier.setDias(dias);
  // }

  Future<void> _adicionarSecao() async {
    final pagina = ref.read(paginaQuiosqueProvider).value;
    if (pagina == null) return;
    final jaAdicionadas =
        pagina.secoes.map((s) => s.nome.toLowerCase()).toSet();
    // Só é possível adicionar seções pré-criadas (cada uma com sua cor),
    // e que ainda não estejam na página.
    final disponiveis = secoesPredefinidas
        .where((s) => !jaAdicionadas.contains(s.nome.toLowerCase()))
        .toList()
      ..sort((a, b) =>
          a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    if (disponiveis.isEmpty) {
      await mostrarAlerta(context,
          mensagem: 'Todas as seções disponíveis já foram adicionadas.');
      return;
    }

    final nome = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Escolha uma seção',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx).colorScheme.outline)),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: disponiveis
                      .map((s) => ListTile(
                            leading: CircleAvatar(radius: 10, backgroundColor: s.cor),
                            title: Text(s.nome,
                                style: TextStyle(
                                    color: Theme.of(ctx).colorScheme.outline)),
                            onTap: () => Navigator.pop(ctx, s.nome),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (nome != null) _executar(() => _notifier.addSecao(nome));
  }

  void _adicionarItem(String secaoId) {
    context.push('/cadastroItem', extra: secaoId);
  }

  void _editarItem(String secaoId, CardapioItem item) {
    context.push('/editarItem', extra: (secaoId: secaoId, item: item));
  }
}
