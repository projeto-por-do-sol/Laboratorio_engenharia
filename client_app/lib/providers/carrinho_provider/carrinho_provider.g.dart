// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carrinho_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CarrinhoNotifier)
final carrinhoProvider = CarrinhoNotifierProvider._();

final class CarrinhoNotifierProvider
    extends
        $NotifierProvider<
          CarrinhoNotifier,
          Map<QuiosqueCarrinho, List<ItemCarrinho>>
        > {
  CarrinhoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carrinhoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carrinhoNotifierHash();

  @$internal
  @override
  CarrinhoNotifier create() => CarrinhoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<QuiosqueCarrinho, List<ItemCarrinho>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<QuiosqueCarrinho, List<ItemCarrinho>>>(value),
    );
  }
}

String _$carrinhoNotifierHash() => r'2ead530a7482b63e6f570e9922433b832745371f';

abstract class _$CarrinhoNotifier
    extends $Notifier<Map<QuiosqueCarrinho, List<ItemCarrinho>>> {
  Map<QuiosqueCarrinho, List<ItemCarrinho>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<QuiosqueCarrinho, List<ItemCarrinho>>,
              Map<QuiosqueCarrinho, List<ItemCarrinho>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<QuiosqueCarrinho, List<ItemCarrinho>>,
                Map<QuiosqueCarrinho, List<ItemCarrinho>>
              >,
              Map<QuiosqueCarrinho, List<ItemCarrinho>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
