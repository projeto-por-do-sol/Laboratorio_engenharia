import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiosque_app/data/api/acompanhamento_api.dart';
import 'package:quiosque_app/data/api/categoria_api.dart';
import 'package:quiosque_app/data/api/item_api.dart';
import 'package:quiosque_app/data/api/quiosque_api.dart';
import 'package:quiosque_app/data/api/models/cardapio_models.dart';
import 'package:quiosque_app/data/api/models/quiosque_models.dart';
import 'package:quiosque_app/src/shared/models/adicionaisItem.dart';
import 'package:quiosque_app/src/shared/models/cardapio_item.dart';
import 'package:quiosque_app/src/shared/models/pagina_quiosque.dart';
import 'package:quiosque_app/src/shared/models/secao.dart';
import 'package:quiosque_app/src/shared/utils/imagem_remota.dart';

/// Página do quiosque carregada da API (`GET /quiosques/me`).
///
/// O cardápio (seções/itens) é persistido via `CategoriaApi`/`ItemApi`/
/// `AcompanhamentoApi`. Após cada alteração recarregamos do servidor para manter
/// o estado autoritativo.
///
/// Nome, horário e raio são persistidos via `PUT /quiosques/me`, que aceita
/// atualização parcial (`QuiosqueUpdateDTO` — só os campos informados). Como o
/// `QuiosqueViewDTO` não devolve o raio (distAtendimento) nem os dias, esses
/// não são relidos do servidor; os dias seguem apenas locais por não terem
/// representação no contrato.
final paginaQuiosqueProvider =
    AsyncNotifierProvider<PaginaQuiosqueNotifier, PaginaQuiosque>(
        PaginaQuiosqueNotifier.new);

/// Indica se a página do quiosque está em modo de edição. Fica fora do widget
/// para que o modo possa ser desligado ao sair da página (troca de aba).
final editandoQuiosqueProvider =
    NotifierProvider<EditandoQuiosqueNotifier, bool>(
        EditandoQuiosqueNotifier.new);

class EditandoQuiosqueNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void definir(bool valor) => state = valor;
}

class PaginaQuiosqueNotifier extends AsyncNotifier<PaginaQuiosque> {
  @override
  Future<PaginaQuiosque> build() => _carregar();

  /// Busca o quiosque do funcionário e converte para o modelo de UI.
  Future<PaginaQuiosque> _carregar() async {
    final view = await QuiosqueApi.instance.buscarMeu();
    return _mapear(view);
  }

  /// Recarrega a página a partir do servidor, refletindo erros no estado.
  Future<void> _recarregar() async {
    state = await AsyncValue.guard(_carregar);
  }

  /// Recarrega passando pelo estado de carregamento. Usado pelo botão "Tentar
  /// novamente" para garantir uma nova tentativa mesmo quando o estado atual já
  /// é um erro em cache (ex.: após reabrir a tela numa nova sessão).
  Future<void> recarregar() async {
    state = const AsyncValue.loading();
    await _recarregar();
  }

  PaginaQuiosque _mapear(QuiosqueView v) {
    return PaginaQuiosque(
      nome: v.nome,
      horarioAbre: v.openingTime,
      horarioFecha: v.closingTime,
      capaPath: v.imagem,
      avaliacao: v.nota ?? 0,
      qtdeAvaliacoes: v.qtdAvaliacoes,
      secoes: v.categorias.map(_mapearSecao).toList(),
      cep: v.cep,
      uf: v.uf,
      cidade: v.cidade,
      latitude: v.latitude,
      longitude: v.longitude,
    );
  }

  Secao _mapearSecao(CategoriaView c) {
    return Secao(
      id: '${c.id}',
      nome: c.nome,
      itens: c.itens.map(_mapearItem).toList(),
    );
  }

  CardapioItem _mapearItem(ItemView i) {
    return CardapioItem(
      id: '${i.id}',
      nome: i.nome,
      descricao: i.descricao ?? '',
      imgPath: i.imagem,
      preco: ((i.valorBase ?? 0) * 100).round(),
      ingredientes: i.ingredientes.map((e) => e.nome).toList(),
      ingredientesIds: {for (final ing in i.ingredientes) ing.nome: ing.id},
      complementos: i.acompanhamentos
          .map((a) => AdicionaisItem(
                id: a.id,
                nomeAdicional: a.nome,
                precoAdicional: ((a.valor ?? 0) * 100).round(),
              ))
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Seções (categorias)
  // ---------------------------------------------------------------------------

  Future<void> addSecao(String nome) async {
    final atual = state.value;
    await CategoriaApi.instance
        .criar(nome: nome, ordem: atual?.secoes.length ?? 0);
    await _recarregar();
  }

  Future<void> removerSecao(String secaoId) async {
    await CategoriaApi.instance.excluir(int.parse(secaoId));
    await _recarregar();
  }

  // ---------------------------------------------------------------------------
  // Itens
  // ---------------------------------------------------------------------------

  /// Cria (quando [itemId] é nulo) ou atualiza um item do cardápio, resolvendo
  /// complementos em acompanhamentos e enviando a imagem se for local.
  Future<void> salvarItem({
    required String secaoId,
    String? itemId,
    required String nome,
    required String descricao,
    required int precoCentavos,
    required List<String> ingredientes,
    required List<AdicionaisItem> complementos,
    String? imagemPath,
  }) async {
    final idCategoria = int.parse(secaoId);

    // Complementos novos (sem id) viram acompanhamentos no servidor; os que já
    // têm id são apenas vinculados.
    final acompanhamentoIds = <int>[];
    for (final c in complementos) {
      if (c.id != null) {
        acompanhamentoIds.add(c.id!);
      } else {
        final criado = await AcompanhamentoApi.instance
            .criar(nome: c.nomeAdicional, valor: c.precoAdicional / 100);
        acompanhamentoIds.add(criado.id);
      }
    }

    final ingredientesBody =
        ingredientes.map((n) => <String, dynamic>{'nome': n}).toList();
    final valorBase = precoCentavos / 100;

    final ItemView salvo;
    if (itemId == null) {
      salvo = await ItemApi.instance.criar(
        idCategoria,
        nome: nome,
        descricao: descricao,
        ingredientes: ingredientesBody,
        acompanhamentoIds: acompanhamentoIds,
        valorBase: valorBase,
      );
    } else {
      salvo = await ItemApi.instance.atualizar(
        idCategoria,
        int.parse(itemId),
        nome: nome,
        descricao: descricao,
        ingredientes: ingredientesBody,
        acompanhamentoIds: acompanhamentoIds,
        valorBase: valorBase,
      );
    }

    // Envia a imagem somente se for um arquivo local recém-escolhido.
    if (imagemPath != null && !ehImagemRemota(imagemPath)) {
      await ItemApi.instance.enviarImagem(idCategoria, salvo.id, imagemPath);
    }

    await _recarregar();
  }

  Future<void> removerItem(String secaoId, String itemId) async {
    await ItemApi.instance.excluir(int.parse(secaoId), int.parse(itemId));
    await _recarregar();
  }

  // ---------------------------------------------------------------------------
  // Cabeçalho (edição local — ver limitação na doc do provider)
  // ---------------------------------------------------------------------------

  void _patch(PaginaQuiosque Function(PaginaQuiosque atual) fn) {
    final atual = state.value;
    if (atual != null) state = AsyncData(fn(atual));
  }

  /// Aplica a edição localmente (otimista) e persiste o(s) campo(s) via
  /// `PUT /quiosques/me` (atualização parcial — só os campos informados). Em
  /// caso de falha, restaura o estado anterior e propaga o erro para a UI.
  Future<void> _persistirCabecalho(
    PaginaQuiosque Function(PaginaQuiosque atual) patch,
    Map<String, dynamic> body,
  ) async {
    final anterior = state.value;
    _patch(patch);
    try {
      await QuiosqueApi.instance.atualizar(body);
    } catch (_) {
      if (anterior != null) state = AsyncData(anterior);
      rethrow;
    }
  }

  Future<void> setNome(String nome) =>
      _persistirCabecalho((a) => a.copyWith(nome: nome), {'nome': nome});

  Future<void> setHorario(String abre, String fecha) => _persistirCabecalho(
        (a) => a.copyWith(horarioAbre: abre, horarioFecha: fecha),
        {'openingTime': abre, 'closingTime': fecha},
      );

  Future<void> setRaio(String raio) => _persistirCabecalho(
        (a) => a.copyWith(raio: raio),
        {'distAtendimento': int.tryParse(raio.trim())},
      );

  /// Os dias de funcionamento ainda não têm representação no contrato da API
  /// (`QuiosqueUpdateDTO`/`QuiosqueViewDTO`), então permanecem apenas locais.
  void setDias(List<bool> dias) =>
      _patch((a) => a.copyWith(diasFuncionamento: dias));

  /// Persiste a localização do quiosque (endereço + coordenadas) via
  /// `PUT /quiosques/me` (atualização parcial), refletindo a mudança no estado
  /// local — sem isso, reabrir a tela de localização mostrava os valores
  /// antigos, como se a alteração não tivesse sido salva.
  Future<void> setLocalizacao({
    required String cep,
    required String cidade,
    required String uf,
    required double latitude,
    required double longitude,
  }) =>
      _persistirCabecalho(
        (a) => a.copyWith(
          cep: cep,
          cidade: cidade,
          uf: uf,
          latitude: latitude,
          longitude: longitude,
        ),
        {
          'cep': cep,
          'cidade': cidade,
          'uf': uf,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

  /// Atualiza o banner. Diferente dos demais campos do cabeçalho, há endpoint
  /// próprio de upload, então a troca é persistida no servidor.
  Future<void> setCapa(String? path) async {
    if (path == null) {
      await QuiosqueApi.instance.removerImagem();
    } else {
      await QuiosqueApi.instance.enviarImagem(path);
    }
    await _recarregar();
  }
}
