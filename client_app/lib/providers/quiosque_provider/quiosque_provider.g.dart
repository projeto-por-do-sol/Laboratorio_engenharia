// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiosque_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lista de quiosques exibida na tela de início.

@ProviderFor(quiosques)
final quiosquesProvider = QuiosquesProvider._();

/// Lista de quiosques exibida na tela de início.

final class QuiosquesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuiosqueModel>>,
          List<QuiosqueModel>,
          FutureOr<List<QuiosqueModel>>
        >
    with
        $FutureModifier<List<QuiosqueModel>>,
        $FutureProvider<List<QuiosqueModel>> {
  /// Lista de quiosques exibida na tela de início.
  QuiosquesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quiosquesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quiosquesHash();

  @$internal
  @override
  $FutureProviderElement<List<QuiosqueModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuiosqueModel>> create(Ref ref) {
    return quiosques(ref);
  }
}

String _$quiosquesHash() => r'43bea41ae3b770347405764305908672ded6753b';

/// Itens vendidos em um quiosque específico.

@ProviderFor(itensQuiosque)
final itensQuiosqueProvider = ItensQuiosqueFamily._();

/// Itens vendidos em um quiosque específico.

final class ItensQuiosqueProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ItemQuiosque>>,
          List<ItemQuiosque>,
          FutureOr<List<ItemQuiosque>>
        >
    with
        $FutureModifier<List<ItemQuiosque>>,
        $FutureProvider<List<ItemQuiosque>> {
  /// Itens vendidos em um quiosque específico.
  ItensQuiosqueProvider._({
    required ItensQuiosqueFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itensQuiosqueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itensQuiosqueHash();

  @override
  String toString() {
    return r'itensQuiosqueProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ItemQuiosque>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ItemQuiosque>> create(Ref ref) {
    final argument = this.argument as String;
    return itensQuiosque(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ItensQuiosqueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itensQuiosqueHash() => r'e97233ce3f591ce0a8294a7225764fc5bc29b909';

/// Itens vendidos em um quiosque específico.

final class ItensQuiosqueFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ItemQuiosque>>, String> {
  ItensQuiosqueFamily._()
    : super(
        retry: null,
        name: r'itensQuiosqueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Itens vendidos em um quiosque específico.

  ItensQuiosqueProvider call(String idQuiosque) =>
      ItensQuiosqueProvider._(argument: idQuiosque, from: this);

  @override
  String toString() => r'itensQuiosqueProvider';
}
