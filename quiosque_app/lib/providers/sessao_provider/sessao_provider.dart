import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiosque_app/src/shared/models/funcionario.dart';
import 'package:quiosque_app/src/shared/models/usuario.dart';

/// Cargo do usuário atualmente logado.
///
/// É definido no momento do login a partir do papel (`role`) retornado pela
/// API (ver [Usuario.cargo]) e as permissões da interface se ajustam.
class CargoAtualNotifier extends Notifier<Cargo> {
  @override
  Cargo build() => Cargo.dono;

  void definir(Cargo cargo) => state = cargo;
}

final cargoAtualProvider =
    NotifierProvider<CargoAtualNotifier, Cargo>(CargoAtualNotifier.new);

/// Usuário autenticado (resposta de `GET /me`). `null` quando não há sessão.
class UsuarioAtualNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  void definir(Usuario? usuario) {
    state = usuario;
    if (usuario != null) {
      ref.read(cargoAtualProvider.notifier).definir(usuario.cargo);
    }
  }
}

final usuarioAtualProvider =
    NotifierProvider<UsuarioAtualNotifier, Usuario?>(UsuarioAtualNotifier.new);
